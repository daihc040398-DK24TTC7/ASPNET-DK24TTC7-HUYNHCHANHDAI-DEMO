<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Orders;

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((Session["Role"] as string) != "Admin")
        {
            Response.Redirect("~/DangNhap.aspx");
            return;
        }

        if (IsPostBack)
        {
            HandleUpdateOrderStatus();
        }

        Orders = DbUtil.Query(@"SELECT dh.DonHangID, nd.HoTen, dh.NgayDat, dh.TongTien, dh.TrangThai
                                FROM DonHang dh INNER JOIN NguoiDung nd ON dh.NguoiDungID = nd.NguoiDungID
                                ORDER BY dh.DonHangID DESC");
    }

    private void HandleUpdateOrderStatus()
    {
        var action = Request.Form["orderAction"];
        if (string.IsNullOrWhiteSpace(action) || !action.StartsWith("update_"))
        {
            return;
        }

        int orderId;
        if (!int.TryParse(action.Substring("update_".Length), out orderId))
        {
            return;
        }

        var status = Request.Form["status_" + orderId];
        if (string.IsNullOrWhiteSpace(status))
        {
            return;
        }

        DbUtil.Execute("UPDATE DonHang SET TrangThai = @TrangThai, NgayCapNhat = GETDATE() WHERE DonHangID = @DonHangID",
            new SqlParameter("@TrangThai", status),
            new SqlParameter("@DonHangID", orderId));

        Response.Redirect(Request.RawUrl);
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Quản lý đơn hàng</h3>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>Mã đơn</th>
                <th>Khách hàng</th>
                <th>Ngày đặt</th>
                <th>Tổng tiền</th>
                <th>Trạng thái</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <% foreach (DataRow row in Orders.Rows) { %>
            <tr>
                <td>#<%= row["DonHangID"] %></td>
                <td><%= row["HoTen"] %></td>
                <td><%= Convert.ToDateTime(row["NgayDat"]).ToString("dd/MM/yyyy HH:mm") %></td>
                <td><%= string.Format("{0:N0}", row["TongTien"]) %> đ</td>
                <td style="width:240px;">
                    <select class="form-select form-select-sm" name="status_<%= row["DonHangID"] %>">
                        <option value="Chờ xác nhận" <%= row["TrangThai"].ToString() == "Chờ xác nhận" ? "selected" : "" %>>Chờ xác nhận</option>
                        <option value="Đang xử lý" <%= row["TrangThai"].ToString() == "Đang xử lý" ? "selected" : "" %>>Đang xử lý</option>
                        <option value="Đang giao" <%= row["TrangThai"].ToString() == "Đang giao" ? "selected" : "" %>>Đang giao</option>
                        <option value="Đã giao" <%= row["TrangThai"].ToString() == "Đã giao" ? "selected" : "" %>>Đã giao</option>
                        <option value="Đã hủy" <%= row["TrangThai"].ToString() == "Đã hủy" ? "selected" : "" %>>Đã hủy</option>
                    </select>
                </td>
                <td>
                    <button type="submit" name="orderAction" value="update_<%= row["DonHangID"] %>" class="btn btn-sm btn-outline-primary">Cập nhật</button>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</asp:Content>

