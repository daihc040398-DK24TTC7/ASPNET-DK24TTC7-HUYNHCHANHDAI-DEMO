<%@ Page Language="C#" MasterPageFile="~/Site.Master" ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Categories;

    protected void Page_Load(object sender, EventArgs e)
    {
        if ((Session["Role"] as string) != "Admin")
        {
            Response.Redirect("~/DangNhap.aspx");
            return;
        }

        int deleteId;
        if (int.TryParse(Request.QueryString["delete"], out deleteId))
        {
            int refCount = Convert.ToInt32(DbUtil.Scalar("SELECT COUNT(*) FROM SanPham WHERE DanhMucID = @DanhMucID", new SqlParameter("@DanhMucID", deleteId)));
            if (refCount > 0)
            {
                DbUtil.Execute("UPDATE DanhMuc SET TrangThai = 0 WHERE DanhMucID = @DanhMucID", new SqlParameter("@DanhMucID", deleteId));
            }
            else
            {
                DbUtil.Execute("DELETE FROM DanhMuc WHERE DanhMucID = @DanhMucID", new SqlParameter("@DanhMucID", deleteId));
            }
            Response.Redirect("~/Admin/QuanLyDanhMuc.aspx");
            return;
        }

        if (!IsPostBack)
        {
            int editId;
            if (int.TryParse(Request.QueryString["edit"], out editId))
            {
                var dt = DbUtil.Query("SELECT TOP 1 * FROM DanhMuc WHERE DanhMucID = @DanhMucID", new SqlParameter("@DanhMucID", editId));
                if (dt.Rows.Count > 0)
                {
                    hfDanhMucID.Value = editId.ToString();
                    txtTenDanhMuc.Text = dt.Rows[0]["TenDanhMuc"].ToString();
                    txtMoTa.Text = dt.Rows[0]["MoTa"] == DBNull.Value ? "" : dt.Rows[0]["MoTa"].ToString();
                    chkTrangThai.Checked = Convert.ToBoolean(dt.Rows[0]["TrangThai"]);
                }
            }
        }

        Categories = DbUtil.Query("SELECT DanhMucID, TenDanhMuc, MoTa, TrangThai FROM DanhMuc ORDER BY DanhMucID DESC");
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtTenDanhMuc.Text))
        {
            lblMessage.CssClass = "text-danger";
            lblMessage.Text = "Tên danh mục không được để trống.";
            return;
        }

        int categoryId;
        if (int.TryParse(hfDanhMucID.Value, out categoryId) && categoryId > 0)
        {
            DbUtil.Execute("UPDATE DanhMuc SET TenDanhMuc = @TenDanhMuc, MoTa = @MoTa, TrangThai = @TrangThai WHERE DanhMucID = @DanhMucID",
                new SqlParameter("@TenDanhMuc", txtTenDanhMuc.Text.Trim()),
                new SqlParameter("@MoTa", string.IsNullOrWhiteSpace(txtMoTa.Text) ? (object)DBNull.Value : txtMoTa.Text.Trim()),
                new SqlParameter("@TrangThai", chkTrangThai.Checked),
                new SqlParameter("@DanhMucID", categoryId));
        }
        else
        {
            DbUtil.Execute("INSERT INTO DanhMuc(TenDanhMuc, MoTa, TrangThai, NgayTao) VALUES(@TenDanhMuc, @MoTa, @TrangThai, GETDATE())",
                new SqlParameter("@TenDanhMuc", txtTenDanhMuc.Text.Trim()),
                new SqlParameter("@MoTa", string.IsNullOrWhiteSpace(txtMoTa.Text) ? (object)DBNull.Value : txtMoTa.Text.Trim()),
                new SqlParameter("@TrangThai", chkTrangThai.Checked));
        }

        Response.Redirect("~/Admin/QuanLyDanhMuc.aspx");
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/Admin/QuanLyDanhMuc.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Quản lý danh mục</h3>

    <div class="card mb-4">
        <div class="card-header"><%= string.IsNullOrWhiteSpace(hfDanhMucID.Value) ? "Thêm danh mục" : "Cập nhật danh mục" %></div>
        <div class="card-body">
            <asp:HiddenField ID="hfDanhMucID" runat="server" />
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Tên danh mục</label>
                    <asp:TextBox ID="txtTenDanhMuc" runat="server" CssClass="form-control" />
                </div>
                <div class="col-md-6">
                    <label class="form-label">Mô tả</label>
                    <asp:TextBox ID="txtMoTa" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" />
                </div>
                <div class="col-md-12 form-check ms-2">
                    <asp:CheckBox ID="chkTrangThai" runat="server" Checked="true" CssClass="form-check-input" />
                    <label class="form-check-label" for="chkTrangThai">Hiển thị danh mục</label>
                </div>
            </div>
            <div class="mt-3">
                <asp:Button ID="btnSave" runat="server" Text="Lưu" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                <asp:Button ID="btnReset" runat="server" Text="Làm mới" CssClass="btn btn-outline-secondary ms-2" OnClick="btnReset_Click" CausesValidation="false" />
            </div>
            <div class="mt-2"><asp:Label ID="lblMessage" runat="server" /></div>
        </div>
    </div>

    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Tên danh mục</th>
                <th>Mô tả</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <% foreach (DataRow row in Categories.Rows) { %>
            <tr>
                <td><%= row["DanhMucID"] %></td>
                <td><%= row["TenDanhMuc"] %></td>
                <td><%= row["MoTa"] == DBNull.Value ? "" : row["MoTa"] %></td>
                <td><%= Convert.ToBoolean(row["TrangThai"]) ? "Hiển thị" : "Ẩn" %></td>
                <td>
                    <a class="btn btn-sm btn-outline-primary" href="<%= ResolveUrl("~/Admin/QuanLyDanhMuc.aspx?edit=" + row["DanhMucID"]) %>">Sửa</a>
                    <a class="btn btn-sm btn-outline-danger" href="<%= ResolveUrl("~/Admin/QuanLyDanhMuc.aspx?delete=" + row["DanhMucID"]) %>" onclick="return confirm('Bạn có chắc muốn ẩn danh mục này?');">Ẩn</a>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</asp:Content>
