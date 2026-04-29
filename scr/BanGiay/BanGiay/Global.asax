<%@ Application Language="C#" %>

<script runat="server">
    protected void Application_BeginRequest(object sender, EventArgs e)
    {
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        Response.Charset = "utf-8";
    }

    protected void Application_AcquireRequestState(object sender, EventArgs e)
    {
        if (Context == null || Context.Session == null || Request == null)
        {
            return;
        }

        var appRelativePath = VirtualPathUtility.ToAppRelative(Request.Path);
        if (!appRelativePath.StartsWith("~/Admin/", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl), true);
            return;
        }

        if (!string.Equals(Session["Role"] as string, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            Response.Redirect("~/Default.aspx", true);
        }
    }
</script>
