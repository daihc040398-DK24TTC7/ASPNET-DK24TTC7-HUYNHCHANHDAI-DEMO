<%@ Page Language="C#" MasterPageFile="~/Site.Master" ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Users;

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((Session["Role"] as string) != "Admin")
        {
            Response.Redirect("~/DangNhap.aspx");
            return;
        }

        if (IsPostBack)
        {
            var action = Request.Form["userAction"];
            if (!string.IsNullOrWhiteSpace(action) && action.StartsWith("toggle_"))
            {
                int userId;
                if (int.TryParse(action.Substring("toggle_".Length), out userId))
                {
                    DbUtil.Execute("UPDATE NguoiDung SET TrangThai = CASE WHEN TrangThai = 1 THEN 0 ELSE 1 END WHERE NguoiDungID = @NguoiDungID",
                        new SqlParameter("@NguoiDungID", userId));
                    Response.Redirect(Request.RawUrl);
                    return;
                }
            }
        }

        Users = DbUtil.Query("SELECT NguoiDungID, HoTen, Email, SoDienThoai, VaiTro, TrangThai, NgayTao FROM NguoiDung ORDER BY NguoiDungID DESC");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Quản lý tài khoản</h3>

    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Họ tên</th>
                <th>Email</th>
                <th>Số điện thoại</th>
                <th>Vai trò</th>
                <th>Trạng thái</th>
                <th>Ngày tạo</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <% foreach (DataRow row in Users.Rows) { %>
            <tr>
                <td><%= row["NguoiDungID"] %></td>
                <td><%= row["HoTen"] %></td>
                <td><%= row["Email"] %></td>
                <td><%= row["SoDienThoai"] == DBNull.Value ? "" : row["SoDienThoai"] %></td>
                <td><span class="badge <%= row["VaiTro"].ToString() == "Admin" ? "text-bg-danger" : "text-bg-info" %>"><%= row["VaiTro"] %></span></td>
                <td><%= Convert.ToBoolean(row["TrangThai"]) ? "Hoạt động" : "Khóa" %></td>
                <td><%= Convert.ToDateTime(row["NgayTao"]).ToString("dd/MM/yyyy") %></td>
                <td>
                    <button type="submit" name="userAction" value="toggle_<%= row["NguoiDungID"] %>" class="btn btn-sm <%= Convert.ToBoolean(row["TrangThai"]) ? "btn-outline-warning" : "btn-outline-success" %>">
                        <%= Convert.ToBoolean(row["TrangThai"]) ? "Khóa" : "Mở" %>
                    </button>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</asp:Content>
