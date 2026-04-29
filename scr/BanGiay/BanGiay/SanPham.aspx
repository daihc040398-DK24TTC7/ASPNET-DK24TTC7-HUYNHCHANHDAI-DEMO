<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Categories;
    protected DataTable Products;
    protected int SelectedCategoryId;

    protected void Page_Load(object sender, EventArgs e)
    {
        int catId;
        if (int.TryParse(Request.QueryString["cat"], out catId))
        {
            SelectedCategoryId = catId;
        }

        Categories = DbUtil.Query("SELECT DanhMucID, TenDanhMuc FROM DanhMuc WHERE TrangThai = 1 ORDER BY TenDanhMuc");

        if (SelectedCategoryId > 0)
        {
            Products = DbUtil.Query(@"SELECT SanPhamID, TenSanPham, Gia, GiaKhuyenMai, HinhAnh, ThuongHieu FROM SanPham WHERE TrangThai = 1 AND DanhMucID = @DanhMucID ORDER BY NgayTao DESC",
                new SqlParameter("@DanhMucID", SelectedCategoryId));
        }
        else
        {
            Products = DbUtil.Query(@"SELECT SanPhamID, TenSanPham, Gia, GiaKhuyenMai, HinhAnh, ThuongHieu FROM SanPham WHERE TrangThai = 1 ORDER BY NgayTao DESC");
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-md-3">
            <div class="card mb-3">
                <div class="card-header">Danh mục</div>
                <div class="list-group list-group-flush">
                    <a href="<%= ResolveUrl("~/SanPham.aspx") %>" class="list-group-item list-group-item-action <%= SelectedCategoryId == 0 ? "active" : "" %>">Tất cả</a>
                    <% foreach (DataRow cat in Categories.Rows) { %>
                        <a href="<%= ResolveUrl("~/SanPham.aspx?cat=" + cat["DanhMucID"]) %>" class="list-group-item list-group-item-action <%= SelectedCategoryId == Convert.ToInt32(cat["DanhMucID"]) ? "active" : "" %>"><%= cat["TenDanhMuc"] %></a>
                    <% } %>
                </div>
            </div>
        </div>
        <div class="col-md-9">
            <h3 class="mb-3">Danh sách sản phẩm</h3>
            <div class="row g-3">
                <% foreach (DataRow row in Products.Rows) { %>
                <div class="col-md-4">
                    <div class="card product-card h-100">
                        <img src="<%= ResolveUrl("~/Images/Products/" + (row["HinhAnh"] == DBNull.Value ? "" : row["HinhAnh"].ToString())) %>" onerror="this.src='https://via.placeholder.com/450x300?text=No+Image'" class="card-img-top" alt="<%= row["TenSanPham"] %>" />
                        <div class="card-body d-flex flex-column">
                            <h6 class="card-title"><%= row["TenSanPham"] %></h6>
                            <small class="text-muted"><%= row["ThuongHieu"] == DBNull.Value ? "" : row["ThuongHieu"] %></small>
                            <div class="mt-auto pt-2">
                                <% if (row["GiaKhuyenMai"] != DBNull.Value) { %>
                                    <span class="price"><%= string.Format("{0:N0}", row["GiaKhuyenMai"]) %> đ</span>
                                    <span class="old-price"><%= string.Format("{0:N0}", row["Gia"]) %> đ</span>
                                <% } else { %>
                                    <span class="price"><%= string.Format("{0:N0}", row["Gia"]) %> đ</span>
                                <% } %>
                            </div>
                        </div>
                        <div class="card-footer bg-white border-0 pt-0">
                            <a href="<%= ResolveUrl("~/ChiTietSanPham.aspx?id=" + row["SanPhamID"]) %>" class="btn btn-outline-primary w-100">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</asp:Content>

