<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected void btnRegister_Click(object sender, EventArgs e)
    {
        var fullName = txtFullName.Text.Trim();
        var email = txtEmail.Text.Trim();
        var password = txtPassword.Text.Trim();
        var phone = txtPhone.Text.Trim();
        var address = txtAddress.Text.Trim();

        if (string.IsNullOrWhiteSpace(fullName) || string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Vui lòng nhập đầy đủ thông tin bắt buộc.";
            return;
        }

        var existed = Convert.ToInt32(DbUtil.Scalar("SELECT COUNT(*) FROM NguoiDung WHERE Email = @Email", new SqlParameter("@Email", email)));
        if (existed > 0)
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Email đã tồn tại.";
            return;
        }

        DbUtil.Execute(@"INSERT INTO NguoiDung(HoTen, Email, MatKhau, SoDienThoai, DiaChi, VaiTro, TrangThai) VALUES(@HoTen, @Email, @MatKhau, @SoDienThoai, @DiaChi, 'KhachHang', 1)",
            new SqlParameter("@HoTen", fullName),
            new SqlParameter("@Email", email),
            new SqlParameter("@MatKhau", AuthUtil.HashPassword(password)),
            new SqlParameter("@SoDienThoai", string.IsNullOrWhiteSpace(phone) ? (object)DBNull.Value : phone),
            new SqlParameter("@DiaChi", string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address));

        lblMessage.CssClass = "text-success";
        lblMessage.Text = "Đăng ký thành công. Bạn có thể đăng nhập.";

        txtFullName.Text = txtEmail.Text = txtPassword.Text = txtPhone.Text = txtAddress.Text = string.Empty;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header"><h5 class="mb-0">Đăng ký tài khoản</h5></div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Họ tên *</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email *</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu *</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Số điện thoại</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Địa chỉ</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" />
                    </div>
                    <asp:Button ID="btnRegister" runat="server" Text="Đăng ký" CssClass="btn btn-primary" OnClick="btnRegister_Click" />
                    <div class="mt-2">
                        <asp:Label ID="lblMessage" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

