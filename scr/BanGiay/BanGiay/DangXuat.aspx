<%@ Page Language="C#"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.Web.Security" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        FormsAuthentication.SignOut();
        Response.Redirect("~/Default.aspx");
    }
</script>

