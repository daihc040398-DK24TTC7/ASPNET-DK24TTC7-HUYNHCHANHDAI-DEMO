<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        if (!IsPostBack)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            var dt = DbUtil.Query("SELECT TOP 1 HoTen, Email, SoDienThoai, DiaChi FROM NguoiDung WHERE NguoiDungID = @NguoiDungID", new SqlParameter("@NguoiDungID", userId));
            if (dt.Rows.Count > 0)
            {
                txtFullName.Text = dt.Rows[0]["HoTen"].ToString();
                txtEmail.Text = dt.Rows[0]["Email"].ToString();
                txtPhone.Text = dt.Rows[0]["SoDienThoai"] == DBNull.Value ? "" : dt.Rows[0]["SoDienThoai"].ToString();
                txtAddress.Text = dt.Rows[0]["DiaChi"] == DBNull.Value ? "" : dt.Rows[0]["DiaChi"].ToString();
            }
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        int userId = Convert.ToInt32(Session["UserId"]);

        DbUtil.Execute(@"UPDATE NguoiDung SET HoTen = @HoTen, SoDienThoai = @SoDienThoai, DiaChi = @DiaChi WHERE NguoiDungID = @NguoiDungID",
            new SqlParameter("@HoTen", txtFullName.Text.Trim()),
            new SqlParameter("@SoDienThoai", string.IsNullOrWhiteSpace(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim()),
            new SqlParameter("@DiaChi", string.IsNullOrWhiteSpace(txtAddress.Text) ? (object)DBNull.Value : txtAddress.Text.Trim()),
            new SqlParameter("@NguoiDungID", userId));

        Session["FullName"] = txtFullName.Text.Trim();
        lblMessage.CssClass = "text-success";
        lblMessage.Text = "Cập nhật thông tin thành công.";
    }

    protected void btnChangePassword_Click(object sender, EventArgs e)
    {
        int userId = Convert.ToInt32(Session["UserId"]);
        var currentPassword = txtCurrentPassword.Text.Trim();
        var newPassword = txtNewPassword.Text.Trim();
        var confirmPassword = txtConfirmPassword.Text.Trim();

        if (string.IsNullOrWhiteSpace(currentPassword) || string.IsNullOrWhiteSpace(newPassword) || string.IsNullOrWhiteSpace(confirmPassword))
        {
            lblPasswordMessage.CssClass = "text-danger";
            lblPasswordMessage.Text = "Vui lòng nhập đầy đủ thông tin đổi mật khẩu.";
            return;
        }

        if (newPassword.Length < 6)
        {
            lblPasswordMessage.CssClass = "text-danger";
            lblPasswordMessage.Text = "Mật khẩu mới phải có ít nhất 6 ký tự.";
            return;
        }

        if (!string.Equals(newPassword, confirmPassword, StringComparison.Ordinal))
        {
            lblPasswordMessage.CssClass = "text-danger";
            lblPasswordMessage.Text = "Mật khẩu xác nhận không khớp.";
            return;
        }

        var storedPasswordObj = DbUtil.Scalar("SELECT MatKhau FROM NguoiDung WHERE NguoiDungID = @NguoiDungID", new SqlParameter("@NguoiDungID", userId));
        var storedPassword = storedPasswordObj == null ? string.Empty : storedPasswordObj.ToString();
        if (!AuthUtil.VerifyPassword(currentPassword, storedPassword))
        {
            lblPasswordMessage.CssClass = "text-danger";
            lblPasswordMessage.Text = "Mật khẩu hiện tại không đúng.";
            return;
        }

        DbUtil.Execute("UPDATE NguoiDung SET MatKhau = @MatKhau WHERE NguoiDungID = @NguoiDungID",
            new SqlParameter("@MatKhau", AuthUtil.HashPassword(newPassword)),
            new SqlParameter("@NguoiDungID", userId));

        txtCurrentPassword.Text = string.Empty;
        txtNewPassword.Text = string.Empty;
        txtConfirmPassword.Text = string.Empty;
        lblPasswordMessage.CssClass = "text-success";
        lblPasswordMessage.Text = "Đổi mật khẩu thành công.";
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Thông tin tài khoản</h3>
    <div class="row">
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">Thông tin tài khoản</div>
                <div class="card-body">
            <div class="mb-3">
                <label class="form-label">Họ tên</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
            </div>
            <div class="mb-3">
                <label class="form-label">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" Enabled="false" />
            </div>
            <div class="mb-3">
                <label class="form-label">Số điện thoại</label>
                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
            </div>
            <div class="mb-3">
                <label class="form-label">Địa chỉ</label>
                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
            </div>
            <asp:Button ID="btnSave" runat="server" Text="Lưu thông tin" CssClass="btn btn-primary" OnClick="btnSave_Click" />
            <div class="mt-2"><asp:Label ID="lblMessage" runat="server" /></div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">Đổi mật khẩu</div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu hiện tại</label>
                        <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu mới</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Xác nhận mật khẩu mới</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" />
                    </div>
                    <asp:Button ID="btnChangePassword" runat="server" Text="Đổi mật khẩu" CssClass="btn btn-outline-primary" OnClick="btnChangePassword_Click" />
                    <div class="mt-2"><asp:Label ID="lblPasswordMessage" runat="server" /></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

