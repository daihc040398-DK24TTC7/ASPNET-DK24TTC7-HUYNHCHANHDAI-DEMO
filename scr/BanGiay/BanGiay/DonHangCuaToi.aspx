<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Orders;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        int userId = Convert.ToInt32(Session["UserId"]);
        Orders = DbUtil.Query("SELECT DonHangID, TongTien, TrangThai, NgayDat FROM DonHang WHERE NguoiDungID = @NguoiDungID ORDER BY DonHangID DESC", new SqlParameter("@NguoiDungID", userId));
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Đơn hàng của tôi</h3>

    <% if (Orders.Rows.Count == 0) { %>
        <div class="alert alert-info">Bạn chưa có đơn hàng nào.</div>
    <% } else { %>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Ngày đặt</th>
                    <th>Trạng thái</th>
                    <th>Tổng tiền</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <% foreach (DataRow row in Orders.Rows) { %>
                <tr>
                    <td>#<%= row["DonHangID"] %></td>
                    <td><%= Convert.ToDateTime(row["NgayDat"]).ToString("dd/MM/yyyy HH:mm") %></td>
                    <td><span class="badge text-bg-secondary badge-status"><%= row["TrangThai"] %></span></td>
                    <td><%= string.Format("{0:N0}", row["TongTien"]) %> đ</td>
                    <td><a class="btn btn-sm btn-outline-primary" href="<%= ResolveUrl("~/ChiTietDonHang.aspx?id=" + row["DonHangID"]) %>">Chi tiết</a></td>
                </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>
</asp:Content>

