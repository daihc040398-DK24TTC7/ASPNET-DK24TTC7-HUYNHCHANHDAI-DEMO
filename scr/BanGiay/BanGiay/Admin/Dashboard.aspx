<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected int TotalProducts;
    protected int TotalUsers;
    protected int TotalOrders;
    protected decimal TotalRevenue;
    protected DataTable LatestOrders;

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((Session["Role"] as string) != "Admin")
        {
            Response.Redirect("~/DangNhap.aspx");
            return;
        }

        TotalProducts = Convert.ToInt32(DbUtil.Scalar("SELECT COUNT(*) FROM SanPham"));
        TotalUsers = Convert.ToInt32(DbUtil.Scalar("SELECT COUNT(*) FROM NguoiDung WHERE VaiTro = 'KhachHang'"));
        TotalOrders = Convert.ToInt32(DbUtil.Scalar("SELECT COUNT(*) FROM DonHang"));
        TotalRevenue = Convert.ToDecimal(DbUtil.Scalar("SELECT ISNULL(SUM(TongTien),0) FROM DonHang"));

        LatestOrders = DbUtil.Query(@"SELECT TOP 10 dh.DonHangID, nd.HoTen, dh.TongTien, dh.TrangThai, dh.NgayDat
                                     FROM DonHang dh
                                     INNER JOIN NguoiDung nd ON dh.NguoiDungID = nd.NguoiDungID
                                     ORDER BY dh.DonHangID DESC");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Admin Dashboard</h3>

    <div class="mb-3">
        <a class="btn btn-outline-primary" href="<%= ResolveUrl("~/Admin/QuanLySanPham.aspx") %>">Quản lý sản phẩm</a>
        <a class="btn btn-outline-success" href="<%= ResolveUrl("~/Admin/QuanLyDanhMuc.aspx") %>">Quản lý danh mục</a>
        <a class="btn btn-outline-dark" href="<%= ResolveUrl("~/Admin/QuanLyTaiKhoan.aspx") %>">Quản lý tài khoản</a>
        <a class="btn btn-outline-secondary" href="<%= ResolveUrl("~/Admin/QuanLyDonHang.aspx") %>">Quản lý đơn hàng</a>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3"><div class="card bg-primary text-white"><div class="card-body"><h6>Sản phẩm</h6><h4><%= TotalProducts %></h4></div></div></div>
        <div class="col-md-3"><div class="card bg-success text-white"><div class="card-body"><h6>Khách hàng</h6><h4><%= TotalUsers %></h4></div></div></div>
        <div class="col-md-3"><div class="card bg-warning text-dark"><div class="card-body"><h6>Đơn hàng</h6><h4><%= TotalOrders %></h4></div></div></div>
        <div class="col-md-3"><div class="card bg-danger text-white"><div class="card-body"><h6>Doanh thu</h6><h5><%= string.Format("{0:N0}", TotalRevenue) %> đ</h5></div></div></div>
    </div>

    <div class="card">
        <div class="card-header">Đơn hàng mới</div>
        <div class="card-body">
            <table class="table table-bordered table-striped mb-0">
                <thead>
                    <tr>
                        <th>Mã đơn</th>
                        <th>Khách hàng</th>
                        <th>Ngày đặt</th>
                        <th>Trạng thái</th>
                        <th>Tổng tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <% foreach (DataRow row in LatestOrders.Rows) { %>
                    <tr>
                        <td>#<%= row["DonHangID"] %></td>
                        <td><%= row["HoTen"] %></td>
                        <td><%= Convert.ToDateTime(row["NgayDat"]).ToString("dd/MM/yyyy HH:mm") %></td>
                        <td><span class="badge text-bg-secondary"><%= row["TrangThai"] %></span></td>
                        <td><%= string.Format("{0:N0}", row["TongTien"]) %> đ</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>

