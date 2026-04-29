<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataRow Product;
    protected DataTable Sizes;

    protected void Page_Load(object sender, EventArgs e)
    {
        int productId;
        if (!int.TryParse(Request.QueryString["id"], out productId))
        {
            Response.Redirect("~/SanPham.aspx");
            return;
        }

        var productTable = DbUtil.Query(@"SELECT sp.*, dm.TenDanhMuc FROM SanPham sp INNER JOIN DanhMuc dm ON sp.DanhMucID = dm.DanhMucID WHERE sp.SanPhamID = @SanPhamID AND sp.TrangThai = 1",
            new SqlParameter("@SanPhamID", productId));

        if (productTable.Rows.Count == 0)
        {
            Response.Redirect("~/SanPham.aspx");
            return;
        }

        Product = productTable.Rows[0];
        Sizes = DbUtil.Query("SELECT KichCoID, Size, SoLuong FROM KichCo WHERE SanPhamID = @SanPhamID AND SoLuong > 0 ORDER BY Size", new SqlParameter("@SanPhamID", productId));

        if (!IsPostBack)
        {
            ddlSize.DataSource = Sizes;
            ddlSize.DataTextField = "Size";
            ddlSize.DataValueField = "KichCoID";
            ddlSize.DataBind();
        }
    }

    protected void btnAddToCart_Click(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        int productId = Convert.ToInt32(Product["SanPhamID"]);
        int userId = Convert.ToInt32(Session["UserId"]);
        int sizeId = 0;
        int.TryParse(ddlSize.SelectedValue, out sizeId);

        int quantity;
        if (!int.TryParse(txtQuantity.Text.Trim(), out quantity) || quantity <= 0)
        {
            quantity = 1;
        }

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

        int inCart = Convert.ToInt32(DbUtil.Scalar(@"SELECT ISNULL(SUM(SoLuong),0) FROM GioHang WHERE NguoiDungID = @NguoiDungID AND SanPhamID = @SanPhamID AND ISNULL(KichCoID,0)=@KichCoID",
            new SqlParameter("@NguoiDungID", userId),
            new SqlParameter("@SanPhamID", productId),
            new SqlParameter("@KichCoID", sizeId)));

        if (inCart + quantity > availableStock)
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Số lượng tồn kho không đủ.";
            return;
        }

        var existed = Convert.ToInt32(DbUtil.Scalar(@"SELECT COUNT(*) FROM GioHang WHERE NguoiDungID = @NguoiDungID AND SanPhamID = @SanPhamID AND ISNULL(KichCoID,0)=@KichCoID",
            new SqlParameter("@NguoiDungID", userId),
            new SqlParameter("@SanPhamID", productId),
            new SqlParameter("@KichCoID", sizeId)));

        if (existed > 0)
        {
            DbUtil.Execute(@"UPDATE GioHang SET SoLuong = SoLuong + @SoLuong WHERE NguoiDungID = @NguoiDungID AND SanPhamID = @SanPhamID AND ISNULL(KichCoID,0)=@KichCoID",
                new SqlParameter("@SoLuong", quantity),
                new SqlParameter("@NguoiDungID", userId),
                new SqlParameter("@SanPhamID", productId),
                new SqlParameter("@KichCoID", sizeId));
        }
        else
        {
            DbUtil.Execute(@"INSERT INTO GioHang(NguoiDungID, SanPhamID, KichCoID, SoLuong) VALUES(@NguoiDungID, @SanPhamID, @KichCoID, @SoLuong)",
                new SqlParameter("@NguoiDungID", userId),
                new SqlParameter("@SanPhamID", productId),
                new SqlParameter("@KichCoID", sizeId == 0 ? (object)DBNull.Value : sizeId),
                new SqlParameter("@SoLuong", quantity));
        }

        lblMessage.CssClass = "text-success";
        lblMessage.Text = "Đã thêm vào giỏ hàng.";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <% if (Product != null) { %>
    <div class="row">
        <div class="col-md-5">
            <img src="<%= ResolveUrl("~/Images/Products/" + (Product["HinhAnh"] == DBNull.Value ? "" : Product["HinhAnh"].ToString())) %>" onerror="this.src='https://via.placeholder.com/600x400?text=No+Image'" class="img-fluid rounded" alt="<%= Product["TenSanPham"] %>" />
        </div>
        <div class="col-md-7">
            <h3><%= Product["TenSanPham"] %></h3>
            <p class="text-muted">Danh mục: <%= Product["TenDanhMuc"] %> | Thương hiệu: <%= Product["ThuongHieu"] == DBNull.Value ? "N/A" : Product["ThuongHieu"] %></p>

            <% if (Product["GiaKhuyenMai"] != DBNull.Value) { %>
                <h4><span class="price"><%= string.Format("{0:N0}", Product["GiaKhuyenMai"]) %> đ</span><span class="old-price"><%= string.Format("{0:N0}", Product["Gia"]) %> đ</span></h4>
            <% } else { %>
                <h4 class="price"><%= string.Format("{0:N0}", Product["Gia"]) %> đ</h4>
            <% } %>

            <p><%= Product["MoTa"] == DBNull.Value ? "" : Product["MoTa"] %></p>

            <div class="row g-2 align-items-end">
                <div class="col-md-4">
                    <label class="form-label">Kích cỡ</label>
                    <asp:DropDownList ID="ddlSize" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-3">
                    <label class="form-label">Số lượng</label>
                    <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control" Text="1" />
                </div>
                <div class="col-md-5">
                    <asp:Button ID="btnAddToCart" runat="server" CssClass="btn btn-success" Text="Thêm vào giỏ hàng" OnClick="btnAddToCart_Click" />
                </div>
            </div>
            <div class="mt-2">
                <asp:Label ID="lblMessage" runat="server" CssClass="text-success" />
            </div>
        </div>
    </div>
    <% } %>
</asp:Content>

