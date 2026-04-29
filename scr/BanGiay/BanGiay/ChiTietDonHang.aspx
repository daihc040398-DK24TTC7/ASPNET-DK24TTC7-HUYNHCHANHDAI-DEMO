<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataRow OrderInfo;
    protected DataTable Details;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        int orderId;
        if (!int.TryParse(Request.QueryString["id"], out orderId))
        {
            Response.Redirect("~/DonHangCuaToi.aspx");
            return;
        }

        int userId = Convert.ToInt32(Session["UserId"]);

        var order = DbUtil.Query("SELECT TOP 1 * FROM DonHang WHERE DonHangID = @DonHangID AND NguoiDungID = @NguoiDungID",
            new SqlParameter("@DonHangID", orderId),
            new SqlParameter("@NguoiDungID", userId));

        if (order.Rows.Count == 0)
        {
            Response.Redirect("~/DonHangCuaToi.aspx");
            return;
        }

        OrderInfo = order.Rows[0];
        Details = DbUtil.Query("SELECT TenSanPham, Size, SoLuong, DonGia FROM ChiTietDonHang WHERE DonHangID = @DonHangID", new SqlParameter("@DonHangID", orderId));
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <% if (OrderInfo != null) { %>
    <h3>Chi tiết đơn hàng #<%= OrderInfo["DonHangID"] %></h3>
    <p><strong>Trạng thái:</strong> <%= OrderInfo["TrangThai"] %></p>
    <p><strong>Người nhận:</strong> <%= OrderInfo["HoTenNguoiNhan"] %> - <%= OrderInfo["SoDienThoai"] %></p>
    <p><strong>Địa chỉ:</strong> <%= OrderInfo["DiaChi"] %></p>

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Sản phẩm</th>
                <th>Size</th>
                <th>Đơn giá</th>
                <th>Số lượng</th>
                <th>Thành tiền</th>
            </tr>
        </thead>
        <tbody>
            <% foreach (DataRow row in Details.Rows) { %>
            <tr>
                <td><%= row["TenSanPham"] %></td>
                <td><%= row["Size"] == DBNull.Value ? "-" : row["Size"] %></td>
                <td><%= string.Format("{0:N0}", row["DonGia"]) %> đ</td>
                <td><%= row["SoLuong"] %></td>
                <td><%= string.Format("{0:N0}", Convert.ToDecimal(row["DonGia"]) * Convert.ToInt32(row["SoLuong"])) %> đ</td>
            </tr>
            <% } %>
        </tbody>
    </table>

    <h5 class="text-end">Tổng cộng: <span class="price"><%= string.Format("{0:N0}", OrderInfo["TongTien"]) %> đ</span></h5>
    <% } %>
</asp:Content>

