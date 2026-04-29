<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.Security" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected void btnLogin_Click(object sender, EventArgs e)
    {
        var email = txtEmail.Text.Trim();
        var password = txtPassword.Text.Trim();

        var dt = DbUtil.Query("SELECT TOP 1 * FROM NguoiDung WHERE Email = @Email AND TrangThai = 1", new SqlParameter("@Email", email));
        if (dt.Rows.Count == 0)
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Email hoặc mật khẩu không đúng.";
            return;
        }

        var user = dt.Rows[0];
        if (!AuthUtil.VerifyPassword(password, user["MatKhau"].ToString()))
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Email hoặc mật khẩu không đúng.";
            return;
        }

        Session["UserId"] = user["NguoiDungID"];
        Session["FullName"] = user["HoTen"].ToString();
        Session["Email"] = user["Email"].ToString();
        Session["Role"] = user["VaiTro"].ToString();

        FormsAuthentication.SetAuthCookie(user["Email"].ToString(), false);

        var returnUrl = Request.QueryString["returnUrl"];
        if (!string.IsNullOrWhiteSpace(returnUrl))
        {
            Response.Redirect(returnUrl);
            return;
        }

        if (user["VaiTro"].ToString() == "Admin")
        {
            Response.Redirect("~/Admin/Dashboard.aspx");
        }
        else
        {
            Response.Redirect("~/Default.aspx");
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card">
                <div class="card-header"><h5 class="mb-0">Đăng nhập</h5></div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" />
                    </div>
                    <asp:Button ID="btnLogin" runat="server" Text="Đăng nhập" CssClass="btn btn-primary" OnClick="btnLogin_Click" />
                    <div class="mt-2">
                        <asp:Label ID="lblMessage" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

