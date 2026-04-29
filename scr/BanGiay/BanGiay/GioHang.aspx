<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable CartItems;
    protected decimal TotalAmount;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["UserId"] == null)
        {
            Response.Redirect("~/DangNhap.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }

        BindCart();
    }

    private void BindCart()
    {
        int userId = Convert.ToInt32(Session["UserId"]);

        CartItems = DbUtil.Query(@"
SELECT gh.GioHangID, gh.SoLuong, sp.SanPhamID, sp.TenSanPham, sp.HinhAnh,
       ISNULL(sp.GiaKhuyenMai, sp.Gia) DonGia, kc.Size
FROM GioHang gh
INNER JOIN SanPham sp ON gh.SanPhamID = sp.SanPhamID
LEFT JOIN KichCo kc ON gh.KichCoID = kc.KichCoID
WHERE gh.NguoiDungID = @NguoiDungID
ORDER BY gh.NgayThem DESC", new SqlParameter("@NguoiDungID", userId));

        TotalAmount = 0;
        foreach (DataRow row in CartItems.Rows)
        {
            TotalAmount += Convert.ToDecimal(row["DonGia"]) * Convert.ToInt32(row["SoLuong"]);
        }

        rptCart.DataSource = CartItems;
        rptCart.DataBind();
    }

    protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        int cartId;
        if (!int.TryParse(e.CommandArgument.ToString(), out cartId))
        {
            return;
        }

        if (e.CommandName == "Remove")
        {
            DbUtil.Execute("DELETE FROM GioHang WHERE GioHangID = @GioHangID", new SqlParameter("@GioHangID", cartId));
        }

        if (e.CommandName == "Update")
        {
            var txtQty = e.Item.FindControl("txtQty") as TextBox;
            int quantity;
            if (txtQty != null && int.TryParse(txtQty.Text, out quantity) && quantity > 0)
            {
                DbUtil.Execute("UPDATE GioHang SET SoLuong = @SoLuong WHERE GioHangID = @GioHangID",
                    new SqlParameter("@SoLuong", quantity),
                    new SqlParameter("@GioHangID", cartId));
            }
        }

        BindCart();
    }

    protected void btnCheckout_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/DatHang.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h3>Giỏ hàng</h3>

    <% if (CartItems.Rows.Count == 0) { %>
        <div class="alert alert-info">Giỏ hàng trống.</div>
    <% } else { %>
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>Ảnh</th>
                    <th>Sản phẩm</th>
                    <th>Size</th>
                    <th>Đơn giá</th>
                    <th>Số lượng</th>
                    <th>Thành tiền</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td style="width:90px;"><img src='<%# ResolveUrl("~/Images/Products/" + (Eval("HinhAnh") == DBNull.Value ? "" : Eval("HinhAnh").ToString())) %>' onerror="this.src='https://via.placeholder.com/80x80?text=Img'" class="img-fluid" /></td>
                            <td><%# Eval("TenSanPham") %></td>
                            <td><%# Eval("Size") == DBNull.Value ? "-" : Eval("Size") %></td>
                            <td><%# string.Format("{0:N0}", Eval("DonGia")) %> đ</td>
                            <td>
                                <asp:TextBox ID="txtQty" runat="server" CssClass="form-control" Width="90" Text='<%# Eval("SoLuong") %>' />
                            </td>
                            <td><%# string.Format("{0:N0}", Convert.ToDecimal(Eval("DonGia")) * Convert.ToInt32(Eval("SoLuong"))) %> đ</td>
                            <td>
                                <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn btn-sm btn-outline-primary me-1" CommandName="Update" CommandArgument='<%# Eval("GioHangID") %>'>Cập nhật</asp:LinkButton>
                                <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn btn-sm btn-outline-danger" CommandName="Remove" CommandArgument='<%# Eval("GioHangID") %>' OnClientClick="return confirm('Xóa sản phẩm này khỏi giỏ hàng?');">Xóa</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>

        <div class="d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Tổng cộng: <span class="price"><%= string.Format("{0:N0}", TotalAmount) %> đ</span></h5>
            <asp:Button ID="btnCheckout" runat="server" CssClass="btn btn-success" Text="Tiến hành đặt hàng" OnClick="btnCheckout_Click" />
        </div>
    <% } %>
</asp:Content>

