<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected decimal TotalAmount;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        int userId = Convert.ToInt32(Session["UserId"]);
        TotalAmount = Convert.ToDecimal(DbUtil.Scalar(@"
SELECT ISNULL(SUM(ISNULL(sp.GiaKhuyenMai, sp.Gia) * gh.SoLuong), 0)
FROM GioHang gh
INNER JOIN SanPham sp ON gh.SanPhamID = sp.SanPhamID
WHERE gh.NguoiDungID = @NguoiDungID", new SqlParameter("@NguoiDungID", userId)));

        if (!IsPostBack)
        {
            var user = DbUtil.Query("SELECT TOP 1 HoTen, SoDienThoai, DiaChi FROM NguoiDung WHERE NguoiDungID = @NguoiDungID", new SqlParameter("@NguoiDungID", userId));
            if (user.Rows.Count > 0)
            {
                txtFullName.Text = user.Rows[0]["HoTen"].ToString();
                txtPhone.Text = user.Rows[0]["SoDienThoai"] == DBNull.Value ? "" : user.Rows[0]["SoDienThoai"].ToString();
                txtAddress.Text = user.Rows[0]["DiaChi"] == DBNull.Value ? "" : user.Rows[0]["DiaChi"].ToString();
            }
        }
    }

    protected void btnPlaceOrder_Click(object sender, EventArgs e)
    {
        int userId = Convert.ToInt32(Session["UserId"]);
        var cart = DbUtil.Query(@"
SELECT gh.SanPhamID, gh.KichCoID, gh.SoLuong, sp.TenSanPham, ISNULL(sp.GiaKhuyenMai, sp.Gia) DonGia, kc.Size
FROM GioHang gh
INNER JOIN SanPham sp ON gh.SanPhamID = sp.SanPhamID
LEFT JOIN KichCo kc ON gh.KichCoID = kc.KichCoID
WHERE gh.NguoiDungID = @NguoiDungID", new SqlParameter("@NguoiDungID", userId));

        if (cart.Rows.Count == 0)
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Giỏ hàng trống.";
            return;
        }

        decimal total = 0;
        foreach (DataRow row in cart.Rows)
        {
            total += Convert.ToDecimal(row["DonGia"]) * Convert.ToInt32(row["SoLuong"]);
        }

        foreach (DataRow row in cart.Rows)
        {
            int cartQty = Convert.ToInt32(row["SoLuong"]);
            int productId = Convert.ToInt32(row["SanPhamID"]);
            int sizeId = row["KichCoID"] == DBNull.Value ? 0 : Convert.ToInt32(row["KichCoID"]);
            int availableStock;

            if (sizeId > 0)
            {
                var stockObj = DbUtil.Scalar("SELECT ISNULL(SoLuong,0) FROM KichCo WHERE KichCoID = @KichCoID", new SqlParameter("@KichCoID", sizeId));
                availableStock = stockObj == null ? 0 : Convert.ToInt32(stockObj);
            }
            else
            {
                var stockObj = DbUtil.Scalar("SELECT ISNULL(SoLuongTon,0) FROM SanPham WHERE SanPhamID = @SanPhamID", new SqlParameter("@SanPhamID", productId));
                availableStock = stockObj == null ? 0 : Convert.ToInt32(stockObj);
            }

            if (cartQty > availableStock)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = string.Format("Sản phẩm '{0}' không đủ tồn kho để đặt hàng.", row["TenSanPham"]);
                return;
            }
        }

        DbUtil.Execute(@"INSERT INTO DonHang(NguoiDungID, HoTenNguoiNhan, SoDienThoai, DiaChi, GhiChu, TongTien, TrangThai, PhuongThucTT, NgayDat) VALUES(@NguoiDungID, @HoTenNguoiNhan, @SoDienThoai, @DiaChi, @GhiChu, @TongTien, N'Chờ xác nhận', N'Tiền mặt', GETDATE())",
            new SqlParameter("@NguoiDungID", userId),
            new SqlParameter("@HoTenNguoiNhan", txtFullName.Text.Trim()),
            new SqlParameter("@SoDienThoai", txtPhone.Text.Trim()),
            new SqlParameter("@DiaChi", txtAddress.Text.Trim()),
            new SqlParameter("@GhiChu", string.IsNullOrWhiteSpace(txtNote.Text) ? (object)DBNull.Value : txtNote.Text.Trim()),
            new SqlParameter("@TongTien", total));

        int orderId = Convert.ToInt32(DbUtil.Scalar("SELECT TOP 1 DonHangID FROM DonHang WHERE NguoiDungID = @NguoiDungID ORDER BY DonHangID DESC", new SqlParameter("@NguoiDungID", userId)));

        foreach (DataRow row in cart.Rows)
        {
            DbUtil.Execute(@"INSERT INTO ChiTietDonHang(DonHangID, SanPhamID, KichCoID, TenSanPham, Size, SoLuong, DonGia) VALUES(@DonHangID, @SanPhamID, @KichCoID, @TenSanPham, @Size, @SoLuong, @DonGia)",
                new SqlParameter("@DonHangID", orderId),
                new SqlParameter("@SanPhamID", row["SanPhamID"]),
                new SqlParameter("@KichCoID", row["KichCoID"] == DBNull.Value ? (object)DBNull.Value : row["KichCoID"]),
                new SqlParameter("@TenSanPham", row["TenSanPham"]),
                new SqlParameter("@Size", row["Size"] == DBNull.Value ? (object)DBNull.Value : row["Size"]),
                new SqlParameter("@SoLuong", row["SoLuong"]),
                new SqlParameter("@DonGia", row["DonGia"]));

            int orderQty = Convert.ToInt32(row["SoLuong"]);
            if (row["KichCoID"] != DBNull.Value)
            {
                DbUtil.Execute("UPDATE KichCo SET SoLuong = CASE WHEN SoLuong >= @SoLuong THEN SoLuong - @SoLuong ELSE 0 END WHERE KichCoID = @KichCoID",
                    new SqlParameter("@SoLuong", orderQty),
                    new SqlParameter("@KichCoID", row["KichCoID"]));
            }

            DbUtil.Execute("UPDATE SanPham SET SoLuongTon = CASE WHEN SoLuongTon >= @SoLuong THEN SoLuongTon - @SoLuong ELSE 0 END WHERE SanPhamID = @SanPhamID",
                new SqlParameter("@SoLuong", orderQty),
                new SqlParameter("@SanPhamID", row["SanPhamID"]));
        }

        DbUtil.Execute("DELETE FROM GioHang WHERE NguoiDungID = @NguoiDungID", new SqlParameter("@NguoiDungID", userId));

        Response.Redirect("~/DonHangCuaToi.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Đặt hàng</h3>

    <div class="row">
        <div class="col-md-7">
            <div class="mb-3">
                <label class="form-label">Họ tên người nhận</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
            </div>
            <div class="mb-3">
                <label class="form-label">Số điện thoại</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
            </div>
            <div class="mb-3">
                <label class="form-label">Địa chỉ</label>
                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
            </div>
            <div class="mb-3">
                <label class="form-label">Ghi chú</label>
                <asp:TextBox ID="txtNote" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
            </div>
            <asp:Button ID="btnPlaceOrder" runat="server" Text="Xác nhận đặt hàng" CssClass="btn btn-success" OnClick="btnPlaceOrder_Click" />
            <div class="mt-2"><asp:Label ID="lblMessage" runat="server" /></div>
        </div>
        <div class="col-md-5">
            <div class="card">
                <div class="card-body">
                    <h5>Tổng thanh toán</h5>
                    <h4 class="price"><%= string.Format("{0:N0}", TotalAmount) %> đ</h4>
                    <small class="text-muted">Thanh toán khi nhận hàng (COD)</small>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

