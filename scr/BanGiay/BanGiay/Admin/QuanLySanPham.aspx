<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Products;
    protected DataTable Categories;
    protected DataTable ProductSizes;

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((Session["Role"] as string) != "Admin")
        {
            Response.Redirect("~/DangNhap.aspx");
            return;
        }

        Page.Form.Enctype = "multipart/form-data";

        int deleteId;
        if (int.TryParse(Request.QueryString["delete"], out deleteId))
        {
            DeleteProduct(deleteId);
            Response.Redirect("~/Admin/QuanLySanPham.aspx");
            return;
        }

        int deleteSizeId;
        if (int.TryParse(Request.QueryString["deleteSize"], out deleteSizeId))
        {
            DeleteSize(deleteSizeId);
            var backProductId = Request.QueryString["edit"];
            Response.Redirect("~/Admin/QuanLySanPham.aspx?edit=" + backProductId);
            return;
        }

        Categories = DbUtil.Query("SELECT DanhMucID, TenDanhMuc FROM DanhMuc WHERE TrangThai = 1 ORDER BY TenDanhMuc");
        BindProducts();

        if (!IsPostBack)
        {
            ddlDanhMuc.DataSource = Categories;
            ddlDanhMuc.DataTextField = "TenDanhMuc";
            ddlDanhMuc.DataValueField = "DanhMucID";
            ddlDanhMuc.DataBind();

            int editId;
            if (int.TryParse(Request.QueryString["edit"], out editId))
            {
                LoadProductForEdit(editId);
                BindSizes(editId);
            }
        }
    }

    private void BindProducts()
    {
        Products = DbUtil.Query(@"SELECT sp.SanPhamID, sp.TenSanPham, sp.HinhAnh, dm.TenDanhMuc, sp.Gia, sp.GiaKhuyenMai, sp.SoLuongTon, sp.TrangThai
                                  FROM SanPham sp INNER JOIN DanhMuc dm ON sp.DanhMucID = dm.DanhMucID
                                  ORDER BY sp.SanPhamID DESC");
    }

    private void LoadProductForEdit(int productId)
    {
        var dt = DbUtil.Query("SELECT TOP 1 * FROM SanPham WHERE SanPhamID = @SanPhamID", new SqlParameter("@SanPhamID", productId));
        if (dt.Rows.Count == 0)
        {
            return;
        }

        var row = dt.Rows[0];
        hfEditingId.Value = productId.ToString();
        ddlDanhMuc.SelectedValue = row["DanhMucID"].ToString();
        txtTenSanPham.Text = row["TenSanPham"].ToString();
        txtThuongHieu.Text = row["ThuongHieu"] == DBNull.Value ? "" : row["ThuongHieu"].ToString();
        txtGia.Text = Convert.ToDecimal(row["Gia"]).ToString("0", CultureInfo.InvariantCulture);
        txtGiaKhuyenMai.Text = row["GiaKhuyenMai"] == DBNull.Value ? "" : Convert.ToDecimal(row["GiaKhuyenMai"]).ToString("0", CultureInfo.InvariantCulture);
        txtSoLuongTon.Text = row["SoLuongTon"].ToString();
        txtMoTa.Text = row["MoTa"] == DBNull.Value ? "" : row["MoTa"].ToString();
        chkTrangThai.Checked = Convert.ToBoolean(row["TrangThai"]);
        hfCurrentImage.Value = row["HinhAnh"] == DBNull.Value ? "" : row["HinhAnh"].ToString();
        litCurrentImage.Text = string.IsNullOrWhiteSpace(hfCurrentImage.Value)
            ? ""
            : "<img src='" + ResolveUrl("~/Images/Products/" + hfCurrentImage.Value) + "' class='img-thumbnail mt-2' style='height:80px;' />";
    }

    private void BindSizes(int productId)
    {
        ProductSizes = DbUtil.Query("SELECT KichCoID, Size, SoLuong FROM KichCo WHERE SanPhamID = @SanPhamID ORDER BY Size", new SqlParameter("@SanPhamID", productId));
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        decimal gia;
        if (!TryParseDecimal(txtGia.Text, out gia) || gia <= 0)
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Giá không hợp lệ.";
            return;
        }

        decimal giaKhuyenMai;
        object giaKhuyenMaiValue = DBNull.Value;
        if (!string.IsNullOrWhiteSpace(txtGiaKhuyenMai.Text))
        {
            if (!TryParseDecimal(txtGiaKhuyenMai.Text, out giaKhuyenMai) || giaKhuyenMai <= 0)
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Giá khuyến mãi không hợp lệ.";
                return;
            }
            giaKhuyenMaiValue = giaKhuyenMai;
        }

        int soLuongTon;
        if (!int.TryParse(txtSoLuongTon.Text, out soLuongTon) || soLuongTon < 0)
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Số lượng tồn không hợp lệ.";
            return;
        }

        string fileName = hfCurrentImage.Value;
        if (fuHinhAnh.HasFile)
        {
            var ext = Path.GetExtension(fuHinhAnh.FileName);
            if (string.IsNullOrWhiteSpace(ext))
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Ảnh không hợp lệ.";
                return;
            }

            ext = ext.ToLowerInvariant();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif" && ext != ".webp")
            {
                lblMessage.CssClass = "text-danger";
                lblMessage.Text = "Chỉ chấp nhận ảnh .jpg, .jpeg, .png, .gif, .webp.";
                return;
            }

            fileName = Guid.NewGuid().ToString("N") + ext;
            var savePath = Server.MapPath("~/Images/Products/" + fileName);
            fuHinhAnh.SaveAs(savePath);
        }

        int editingId;
        if (int.TryParse(hfEditingId.Value, out editingId) && editingId > 0)
        {
            DbUtil.Execute(@"UPDATE SanPham
                           SET DanhMucID = @DanhMucID, TenSanPham = @TenSanPham, MoTa = @MoTa, Gia = @Gia,
                               GiaKhuyenMai = @GiaKhuyenMai, HinhAnh = @HinhAnh, ThuongHieu = @ThuongHieu,
                               SoLuongTon = @SoLuongTon, TrangThai = @TrangThai
                           WHERE SanPhamID = @SanPhamID",
                new SqlParameter("@DanhMucID", Convert.ToInt32(ddlDanhMuc.SelectedValue)),
                new SqlParameter("@TenSanPham", txtTenSanPham.Text.Trim()),
                new SqlParameter("@MoTa", string.IsNullOrWhiteSpace(txtMoTa.Text) ? (object)DBNull.Value : txtMoTa.Text.Trim()),
                new SqlParameter("@Gia", gia),
                new SqlParameter("@GiaKhuyenMai", giaKhuyenMaiValue),
                new SqlParameter("@HinhAnh", string.IsNullOrWhiteSpace(fileName) ? (object)DBNull.Value : fileName),
                new SqlParameter("@ThuongHieu", string.IsNullOrWhiteSpace(txtThuongHieu.Text) ? (object)DBNull.Value : txtThuongHieu.Text.Trim()),
                new SqlParameter("@SoLuongTon", soLuongTon),
                new SqlParameter("@TrangThai", chkTrangThai.Checked),
                new SqlParameter("@SanPhamID", editingId));
        }
        else
        {
            DbUtil.Execute(@"INSERT INTO SanPham(DanhMucID, TenSanPham, MoTa, Gia, GiaKhuyenMai, HinhAnh, ThuongHieu, SoLuongTon, TrangThai, NgayTao)
                           VALUES(@DanhMucID, @TenSanPham, @MoTa, @Gia, @GiaKhuyenMai, @HinhAnh, @ThuongHieu, @SoLuongTon, @TrangThai, GETDATE())",
                new SqlParameter("@DanhMucID", Convert.ToInt32(ddlDanhMuc.SelectedValue)),
                new SqlParameter("@TenSanPham", txtTenSanPham.Text.Trim()),
                new SqlParameter("@MoTa", string.IsNullOrWhiteSpace(txtMoTa.Text) ? (object)DBNull.Value : txtMoTa.Text.Trim()),
                new SqlParameter("@Gia", gia),
                new SqlParameter("@GiaKhuyenMai", giaKhuyenMaiValue),
                new SqlParameter("@HinhAnh", string.IsNullOrWhiteSpace(fileName) ? (object)DBNull.Value : fileName),
                new SqlParameter("@ThuongHieu", string.IsNullOrWhiteSpace(txtThuongHieu.Text) ? (object)DBNull.Value : txtThuongHieu.Text.Trim()),
                new SqlParameter("@SoLuongTon", soLuongTon),
                new SqlParameter("@TrangThai", chkTrangThai.Checked));
        }

        Response.Redirect("~/Admin/QuanLySanPham.aspx");
    }

    protected void btnAddSize_Click(object sender, EventArgs e)
    {
        int productId;
        if (!int.TryParse(hfEditingId.Value, out productId) || productId <= 0)
        {
            lblSizeMessage.CssClass = "text-danger";
            lblSizeMessage.Text = "Hãy lưu sản phẩm trước khi quản lý size.";
            return;
        }

        var sizeText = txtSize.Text.Trim();
        int sizeQty;
        if (string.IsNullOrWhiteSpace(sizeText) || !int.TryParse(txtSizeQty.Text, out sizeQty) || sizeQty < 0)
        {
            lblSizeMessage.CssClass = "text-danger";
            lblSizeMessage.Text = "Size hoặc số lượng không hợp lệ.";
            return;
        }

        int existed = Convert.ToInt32(DbUtil.Scalar("SELECT COUNT(*) FROM KichCo WHERE SanPhamID = @SanPhamID AND Size = @Size",
            new SqlParameter("@SanPhamID", productId),
            new SqlParameter("@Size", sizeText)));

        if (existed > 0)
        {
            DbUtil.Execute("UPDATE KichCo SET SoLuong = @SoLuong WHERE SanPhamID = @SanPhamID AND Size = @Size",
                new SqlParameter("@SoLuong", sizeQty),
                new SqlParameter("@SanPhamID", productId),
                new SqlParameter("@Size", sizeText));
        }
        else
        {
            DbUtil.Execute("INSERT INTO KichCo(SanPhamID, Size, SoLuong) VALUES(@SanPhamID, @Size, @SoLuong)",
                new SqlParameter("@SanPhamID", productId),
                new SqlParameter("@Size", sizeText),
                new SqlParameter("@SoLuong", sizeQty));
        }

        txtSize.Text = string.Empty;
        txtSizeQty.Text = "0";
        Response.Redirect("~/Admin/QuanLySanPham.aspx?edit=" + productId);
    }

    private void DeleteSize(int sizeId)
    {
        int refCount = Convert.ToInt32(DbUtil.Scalar(@"SELECT
            (SELECT COUNT(*) FROM GioHang WHERE KichCoID = @KichCoID) +
            (SELECT COUNT(*) FROM ChiTietDonHang WHERE KichCoID = @KichCoID)",
            new SqlParameter("@KichCoID", sizeId)));

        if (refCount > 0)
        {
            DbUtil.Execute("UPDATE KichCo SET SoLuong = 0 WHERE KichCoID = @KichCoID", new SqlParameter("@KichCoID", sizeId));
            return;
        }

        DbUtil.Execute("DELETE FROM KichCo WHERE KichCoID = @KichCoID", new SqlParameter("@KichCoID", sizeId));
    }

    private void DeleteProduct(int productId)
    {
        int refCount = Convert.ToInt32(DbUtil.Scalar(@"SELECT
            (SELECT COUNT(*) FROM GioHang WHERE SanPhamID = @SanPhamID) +
            (SELECT COUNT(*) FROM ChiTietDonHang WHERE SanPhamID = @SanPhamID)",
            new SqlParameter("@SanPhamID", productId)));

        if (refCount > 0)
        {
            DbUtil.Execute("UPDATE SanPham SET TrangThai = 0 WHERE SanPhamID = @SanPhamID", new SqlParameter("@SanPhamID", productId));
            return;
        }

        DbUtil.Execute("DELETE FROM KichCo WHERE SanPhamID = @SanPhamID", new SqlParameter("@SanPhamID", productId));
        DbUtil.Execute("DELETE FROM SanPham WHERE SanPhamID = @SanPhamID", new SqlParameter("@SanPhamID", productId));
    }

    private bool TryParseDecimal(string input, out decimal value)
    {
        if (decimal.TryParse(input, NumberStyles.Any, CultureInfo.InvariantCulture, out value))
        {
            return true;
        }
        return decimal.TryParse(input, NumberStyles.Any, CultureInfo.GetCultureInfo("vi-VN"), out value);
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/QuanLySanPham.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Quản lý sản phẩm</h3>

    <div class="card mb-4">
        <div class="card-header"><%= string.IsNullOrWhiteSpace(hfEditingId.Value) ? "Thêm sản phẩm" : "Cập nhật sản phẩm" %></div>
        <div class="card-body">
            <asp:HiddenField ID="hfEditingId" runat="server" />
            <asp:HiddenField ID="hfCurrentImage" runat="server" />

            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Danh mục</label>
                    <asp:DropDownList ID="ddlDanhMuc" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-8">
                    <label class="form-label">Tên sản phẩm</label>
                    <asp:TextBox ID="txtTenSanPham" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">Thương hiệu</label>
                    <asp:TextBox ID="txtThuongHieu" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label">Giá</label>
                    <asp:TextBox ID="txtGia" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label">Giá khuyến mãi</label>
                    <asp:TextBox ID="txtGiaKhuyenMai" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-2">
                    <label class="form-label">Tồn kho</label>
                    <asp:TextBox ID="txtSoLuongTon" runat="server" CssClass="form-control" Text="0" />
                </div>
                <div class="col-md-6">
                    <label class="form-label">Ảnh sản phẩm</label>
                    <asp:FileUpload ID="fuHinhAnh" runat="server" CssClass="form-control" />
                    <asp:Literal ID="litCurrentImage" runat="server" />
                </div>
                <div class="col-md-6">
                    <label class="form-label">Mô tả</label>
                    <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                </div>
                <div class="col-md-12 form-check ms-2">
                    <asp:CheckBox ID="chkTrangThai" runat="server" Checked="true" CssClass="form-check-input" />
                    <label class="form-check-label" for="chkTrangThai">Hiển thị sản phẩm</label>
                </div>
            </div>

            <div class="mt-3">
                <asp:Button ID="btnSave" runat="server" Text="Lưu" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary ms-2" OnClick="btnReset_Click" CausesValidation="false" />
            </div>
            <div class="mt-2"><asp:Label ID="lblMessage" runat="server" /></div>
        </div>
    </div>

    <% if (!string.IsNullOrWhiteSpace(hfEditingId.Value)) { %>
    <div class="card mb-4">
        <div class="card-header">Quản lý size cho sản phẩm</div>
        <div class="card-body">
            <div class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label">Size</label>
                    <asp:TextBox ID="txtSize" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-3">
                    <label class="form-label">Số lượng</label>
                    <asp:TextBox ID="txtSizeQty" runat="server" CssClass="form-control" Text="0" />
                </div>
                <div class="col-md-3">
                    <asp:Button ID="btnAddSize" runat="server" Text="Lưu size" CssClass="btn btn-outline-primary" OnClick="btnAddSize_Click" />
                </div>
            </div>
            <div class="mt-2"><asp:Label ID="lblSizeMessage" runat="server" /></div>

            <table class="table table-bordered table-striped mt-3 mb-0">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Size</th>
                        <th>Số lượng</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% foreach (DataRow s in ProductSizes.Rows) { %>
                    <tr>
                        <td><%= s["KichCoID"] %></td>
                        <td><%= s["Size"] %></td>
                        <td><%= s["SoLuong"] %></td>
                        <td>
                            <a class="btn btn-sm btn-outline-danger" href="<%= ResolveUrl("~/Admin/QuanLySanPham.aspx?edit=" + hfEditingId.Value + "&deleteSize=" + s["KichCoID"]) %>" onclick="return confirm('Bạn có chắc muốn xóa size này?');">Xóa size</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>

    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Ảnh</th>
                <th>Tên sản phẩm</th>
                <th>Danh mục</th>
                <th>Giá</th>
                <th>Giá KM</th>
                <th>Tồn kho</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <% foreach (DataRow row in Products.Rows) { %>
            <tr>
                <td><%= row["SanPhamID"] %></td>
                <td style="width:80px;"><img src="<%= ResolveUrl("~/Images/Products/" + (row["HinhAnh"] == DBNull.Value ? "" : row["HinhAnh"].ToString())) %>" onerror="this.src='https://via.placeholder.com/60x60?text=Img'" class="img-thumbnail" style="height:60px;" /></td>
                <td><%= row["TenSanPham"] %></td>
                <td><%= row["TenDanhMuc"] %></td>
                <td><%= string.Format("{0:N0}", row["Gia"]) %> đ</td>
                <td><%= row["GiaKhuyenMai"] == DBNull.Value ? "-" : string.Format("{0:N0}", row["GiaKhuyenMai"]) + " đ" %></td>
                <td><%= row["SoLuongTon"] %></td>
                <td><%= Convert.ToBoolean(row["TrangThai"]) ? "Hiển thị" : "Ẩn" %></td>
                <td style="width:160px;">
                    <a class="btn btn-sm btn-outline-primary" href="<%= ResolveUrl("~/Admin/QuanLySanPham.aspx?edit=" + row["SanPhamID"]) %>">Sửa</a>
                    <a class="btn btn-sm btn-outline-danger" href="<%= ResolveUrl("~/Admin/QuanLySanPham.aspx?delete=" + row["SanPhamID"]) %>" onclick="return confirm('Bạn có chắc muốn xóa sản phẩm này?');">Xóa</a>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</asp:Content>

