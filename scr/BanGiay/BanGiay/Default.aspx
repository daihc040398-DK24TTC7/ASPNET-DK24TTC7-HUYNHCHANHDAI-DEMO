<%@ Page Language="C#" MasterPageFile="~/Site.Master"  ResponseEncoding="utf-8" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="BanGiay" %>

<script runat="server">
    protected DataTable Products;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            Products = DbUtil.Query(@"SELECT TOP 8 SanPhamID, TenSanPham, Gia, GiaKhuyenMai, HinhAnh FROM SanPham WHERE TrangThai = 1 ORDER BY NgayTao DESC");
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Hero Banner -->
    <div class="hero-banner fade-up">
        <div class="row align-items-center">
            <div class="col-lg-7">
                <div class="hero-badge">
                    <i class="fa-solid fa-bolt"></i> Bộ sưu tập mới 2026
                </div>
                <h1 class="hero-title">Bước đi tự tin<br>với <span>đôi giày</span> hoàn hảo</h1>
                <p class="hero-sub">Khám phá hàng trăm mẫu giày chính hãng, phong cách – từ Oxford lịch lãm đến sneaker năng động.</p>
                <div class="hero-actions">
                    <a class="btn-hero-primary" href="<%= ResolveUrl("~/SanPham.aspx") %>">
                        <i class="fa-solid fa-bags-shopping"></i> Mua sắm ngay
                    </a>
                    <a class="btn-hero-secondary" href="<%= ResolveUrl("~/SanPham.aspx") %>">
                        Xem tất cả <i class="fa-solid fa-arrow-right"></i>
                    </a>
                </div>
                <div class="hero-stats">
                    <div>
                        <div class="hero-stat-num">500+</div>
                        <div class="hero-stat-label">Sản phẩm</div>
                    </div>
                    <div>
                        <div class="hero-stat-num">50+</div>
                        <div class="hero-stat-label">Thương hiệu</div>
                    </div>
                    <div>
                        <div class="hero-stat-num">10k+</div>
                        <div class="hero-stat-label">Khách hàng</div>
                    </div>
                </div>
            </div>
            <div class="col-lg-5 d-none d-lg-flex justify-content-end align-items-center">
                <div style="font-size:10rem; opacity:.15; line-height:1;">
                    <i class="fa-solid fa-shoe-prints"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Product Grid -->
    <div class="section-heading fade-up">
        <h2 class="section-title">Sản phẩm mới</h2>
        <a class="section-link" href="<%= ResolveUrl("~/SanPham.aspx") %>">Xem tất cả <i class="fa-solid fa-arrow-right"></i></a>
    </div>

    <div class="row g-4">
        <% if (Products != null) {
            int i = 0;
            foreach (DataRow row in Products.Rows) {
                decimal gia = Convert.ToDecimal(row["Gia"]);
                bool coKhuyenMai = row["GiaKhuyenMai"] != DBNull.Value;
                decimal giaHienThi = coKhuyenMai ? Convert.ToDecimal(row["GiaKhuyenMai"]) : gia;
                int pctOff = coKhuyenMai ? (int)Math.Round((1 - giaHienThi / gia) * 100) : 0;
                i++;
        %>
            <div class="col-6 col-md-4 col-lg-3 fade-up delay-<%= (i % 4) + 1 %>">
                <div class="card product-card h-100">
                    <div class="product-card-img-wrap">
                        <img src="<%= ResolveUrl("~/Images/Products/" + (row["HinhAnh"] == DBNull.Value ? "no-image.jpg" : row["HinhAnh"].ToString())) %>"
                             alt="<%= row["TenSanPham"] %>" loading="lazy" />
                        <% if (coKhuyenMai) { %><span class="product-card-badge">-<%= pctOff %>%</span><% } %>
                        <div class="product-card-actions">
                            <a href="<%= ResolveUrl("~/ChiTietSanPham.aspx?id=" + row["SanPhamID"]) %>">
                                <i class="fa-solid fa-eye"></i> Xem chi tiết
                            </a>
                        </div>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <h6 class="card-title"><%= row["TenSanPham"] %></h6>
                        <div class="mt-auto">
                            <span class="price"><%= string.Format("{0:N0}", giaHienThi) %> đ</span>
                            <% if (coKhuyenMai) { %>
                                <span class="old-price"><%= string.Format("{0:N0}", gia) %> đ</span>
                                <span class="discount-pct">-<%= pctOff %>%</span>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        <% }} %>
    </div>

    <!-- Features strip -->
    <div class="row g-3 mt-4 fade-up">
        <div class="col-6 col-md-3">
            <div class="card text-center p-3">
                <div style="font-size:1.8rem; color:var(--brand); margin-bottom:8px;"><i class="fa-solid fa-truck-fast"></i></div>
                <div style="font-weight:700; font-size:.85rem; color:var(--navy);">Giao hàng nhanh</div>
                <div style="font-size:.78rem; color:var(--muted);">Toàn quốc 2–4 ngày</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card text-center p-3">
                <div style="font-size:1.8rem; color:var(--brand); margin-bottom:8px;"><i class="fa-solid fa-shield-check"></i></div>
                <div style="font-weight:700; font-size:.85rem; color:var(--navy);">Chính hãng 100%</div>
                <div style="font-size:.78rem; color:var(--muted);">Cam kết nguồn gốc</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card text-center p-3">
                <div style="font-size:1.8rem; color:var(--brand); margin-bottom:8px;"><i class="fa-solid fa-rotate-left"></i></div>
                <div style="font-weight:700; font-size:.85rem; color:var(--navy);">Đổi trả 30 ngày</div>
                <div style="font-size:.78rem; color:var(--muted);">Miễn phí đổi size</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="card text-center p-3">
                <div style="font-size:1.8rem; color:var(--brand); margin-bottom:8px;"><i class="fa-solid fa-headset"></i></div>
                <div style="font-weight:700; font-size:.85rem; color:var(--navy);">Hỗ trợ 24/7</div>
                <div style="font-size:.78rem; color:var(--muted);">Tư vấn tận tình</div>
            </div>
        </div>
    </div>
</asp:Content>

