# Script for populating the database with e-commerce example data.
#
# Run with: mix run priv/repo/seeds.exs
#
# This creates sample data that matches the examples in SELECTO_GUIDE.md

alias SelectoExamples.Repo
alias SelectoExamples.Catalog.{Category, Supplier, Product, Tag, Review}
alias SelectoExamples.Sales.{Customer, Order, OrderItem}
alias SelectoExamples.Hr.Employee

import Ecto.Query

IO.puts("Seeding database...")

# Clear existing data
Repo.delete_all(Review)
Repo.delete_all(OrderItem)
Repo.delete_all(Order)
Repo.delete_all("product_tags")
Repo.delete_all(Product)
Repo.delete_all(Tag)
Repo.delete_all(Category)
Repo.delete_all(Supplier)
Repo.delete_all(Customer)
Repo.delete_all(Employee)

# Reset sequences
Repo.query!("ALTER SEQUENCE categories_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE suppliers_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE products_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE tags_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE customers_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE orders_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE order_items_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE employees_id_seq RESTART WITH 1")
Repo.query!("ALTER SEQUENCE reviews_id_seq RESTART WITH 1")

IO.puts("Creating categories...")

categories = [
  %{name: "Electronics", description: "Electronic devices and gadgets", slug: "electronics"},
  %{name: "Clothing", description: "Apparel and fashion items", slug: "clothing"},
  %{name: "Home & Garden", description: "Home improvement and garden supplies", slug: "home-garden"},
  %{name: "Sports & Outdoors", description: "Sporting goods and outdoor equipment", slug: "sports-outdoors"},
  %{name: "Books", description: "Books and publications", slug: "books"},
  %{name: "Accessories", description: "Electronic and fashion accessories", slug: "accessories"},
  %{name: "Food & Beverages", description: "Food items and drinks", slug: "food-beverages"},
  %{name: "Health & Beauty", description: "Health and beauty products", slug: "health-beauty"}
]

categories = Enum.map(categories, fn attrs ->
  {:ok, category} = %Category{} |> Category.changeset(attrs) |> Repo.insert()
  category
end)

IO.puts("Creating suppliers...")

suppliers = [
  %{company_name: "TechWorld Inc", contact_name: "John Smith", contact_title: "Sales Manager",
    email: "john@techworld.com", phone: "555-0101", city: "San Francisco", country: "USA", active: true},
  %{company_name: "Fashion Forward Ltd", contact_name: "Emma Wilson", contact_title: "Account Executive",
    email: "emma@fashionforward.com", phone: "555-0102", city: "New York", country: "USA", active: true},
  %{company_name: "Home Essentials Co", contact_name: "Michael Brown", contact_title: "Sales Rep",
    email: "michael@homeessentials.com", phone: "555-0103", city: "Chicago", country: "USA", active: true},
  %{company_name: "SportsPro International", contact_name: "Sarah Davis", contact_title: "Director",
    email: "sarah@sportspro.com", phone: "555-0104", city: "Denver", country: "USA", active: true},
  %{company_name: "Global Books Distribution", contact_name: "David Lee", contact_title: "Manager",
    email: "david@globalbooks.com", phone: "555-0105", city: "Boston", country: "USA", active: true},
  %{company_name: "AccessoryHub", contact_name: "Lisa Chen", contact_title: "Sales Lead",
    email: "lisa@accessoryhub.com", phone: "555-0106", city: "Los Angeles", country: "USA", active: true},
  %{company_name: "FreshFoods Ltd", contact_name: "Tom Garcia", contact_title: "Account Manager",
    email: "tom@freshfoods.com", phone: "555-0107", city: "Miami", country: "USA", active: true},
  %{company_name: "BeautyFirst Supplies", contact_name: "Amy Johnson", contact_title: "Sales Director",
    email: "amy@beautyfirst.com", phone: "555-0108", city: "Seattle", country: "USA", active: true}
]

suppliers = Enum.map(suppliers, fn attrs ->
  {:ok, supplier} = %Supplier{} |> Supplier.changeset(attrs) |> Repo.insert()
  supplier
end)

IO.puts("Creating tags...")

tags = [
  %{name: "Featured", slug: "featured", description: "Featured products"},
  %{name: "New Arrival", slug: "new-arrival", description: "Recently added products"},
  %{name: "Best Seller", slug: "best-seller", description: "Top selling products"},
  %{name: "On Sale", slug: "on-sale", description: "Discounted products"},
  %{name: "Premium", slug: "premium", description: "Premium quality products"},
  %{name: "Eco-Friendly", slug: "eco-friendly", description: "Environmentally friendly products"},
  %{name: "Limited Edition", slug: "limited-edition", description: "Limited availability"},
  %{name: "Gift Idea", slug: "gift-idea", description: "Great gift ideas"}
]

tags = Enum.map(tags, fn attrs ->
  {:ok, tag} = %Tag{} |> Tag.changeset(attrs) |> Repo.insert()
  tag
end)

IO.puts("Creating products...")

products_data = [
  # Electronics (category 1, supplier 1)
  %{name: "Wireless Bluetooth Headphones", sku: "ELEC-001", price: Decimal.new("79.99"),
    cost: Decimal.new("45.00"), stock_quantity: 150, featured: true,
    category_id: 1, supplier_id: 1, tags: ["electronics", "audio"], active: true},
  %{name: "Smart Watch Pro", sku: "ELEC-002", price: Decimal.new("249.99"),
    cost: Decimal.new("150.00"), stock_quantity: 75, featured: true,
    category_id: 1, supplier_id: 1, tags: ["electronics", "wearable"], active: true},
  %{name: "Portable Power Bank 20000mAh", sku: "ELEC-003", price: Decimal.new("39.99"),
    cost: Decimal.new("22.00"), stock_quantity: 200, featured: false,
    category_id: 1, supplier_id: 1, tags: ["electronics", "mobile"], active: true},
  %{name: "USB-C Hub 7-in-1", sku: "ELEC-004", price: Decimal.new("59.99"),
    cost: Decimal.new("30.00"), stock_quantity: 120, featured: false,
    category_id: 1, supplier_id: 1, tags: ["electronics", "computer"], active: true},
  %{name: "Wireless Charging Pad", sku: "ELEC-005", price: Decimal.new("29.99"),
    cost: Decimal.new("15.00"), stock_quantity: 180, featured: false,
    category_id: 1, supplier_id: 1, tags: ["electronics", "mobile"], active: true},

  # Clothing (category 2, supplier 2)
  %{name: "Premium Cotton T-Shirt", sku: "CLTH-001", price: Decimal.new("24.99"),
    cost: Decimal.new("10.00"), stock_quantity: 500, featured: false,
    category_id: 2, supplier_id: 2, tags: ["clothing", "casual"], active: true},
  %{name: "Slim Fit Jeans", sku: "CLTH-002", price: Decimal.new("69.99"),
    cost: Decimal.new("35.00"), stock_quantity: 300, featured: true,
    category_id: 2, supplier_id: 2, tags: ["clothing", "denim"], active: true},
  %{name: "Wool Winter Jacket", sku: "CLTH-003", price: Decimal.new("149.99"),
    cost: Decimal.new("80.00"), stock_quantity: 100, featured: true,
    category_id: 2, supplier_id: 2, tags: ["clothing", "outerwear"], active: true},
  %{name: "Running Shorts", sku: "CLTH-004", price: Decimal.new("34.99"),
    cost: Decimal.new("15.00"), stock_quantity: 250, featured: false,
    category_id: 2, supplier_id: 2, tags: ["clothing", "athletic"], active: true},
  %{name: "Casual Hoodie", sku: "CLTH-005", price: Decimal.new("54.99"),
    cost: Decimal.new("25.00"), stock_quantity: 200, featured: false,
    category_id: 2, supplier_id: 2, tags: ["clothing", "casual"], active: true},

  # Home & Garden (category 3, supplier 3)
  %{name: "Stainless Steel Cookware Set", sku: "HOME-001", price: Decimal.new("199.99"),
    cost: Decimal.new("100.00"), stock_quantity: 50, featured: true,
    category_id: 3, supplier_id: 3, tags: ["kitchen", "cookware"], active: true},
  %{name: "Memory Foam Pillow", sku: "HOME-002", price: Decimal.new("49.99"),
    cost: Decimal.new("20.00"), stock_quantity: 150, featured: false,
    category_id: 3, supplier_id: 3, tags: ["bedroom", "comfort"], active: true},
  %{name: "LED Desk Lamp", sku: "HOME-003", price: Decimal.new("44.99"),
    cost: Decimal.new("22.00"), stock_quantity: 180, featured: false,
    category_id: 3, supplier_id: 3, tags: ["lighting", "office"], active: true},
  %{name: "Garden Tool Set 5-Piece", sku: "HOME-004", price: Decimal.new("39.99"),
    cost: Decimal.new("18.00"), stock_quantity: 120, featured: false,
    category_id: 3, supplier_id: 3, tags: ["garden", "tools"], active: true},
  %{name: "Indoor Plant Pot Set", sku: "HOME-005", price: Decimal.new("29.99"),
    cost: Decimal.new("12.00"), stock_quantity: 200, featured: false,
    category_id: 3, supplier_id: 3, tags: ["garden", "decor"], active: true},

  # Sports & Outdoors (category 4, supplier 4)
  %{name: "Yoga Mat Premium", sku: "SPRT-001", price: Decimal.new("39.99"),
    cost: Decimal.new("18.00"), stock_quantity: 200, featured: true,
    category_id: 4, supplier_id: 4, tags: ["fitness", "yoga"], active: true},
  %{name: "Adjustable Dumbbells Set", sku: "SPRT-002", price: Decimal.new("299.99"),
    cost: Decimal.new("150.00"), stock_quantity: 40, featured: true,
    category_id: 4, supplier_id: 4, tags: ["fitness", "weights"], active: true},
  %{name: "Camping Tent 4-Person", sku: "SPRT-003", price: Decimal.new("179.99"),
    cost: Decimal.new("90.00"), stock_quantity: 60, featured: false,
    category_id: 4, supplier_id: 4, tags: ["camping", "outdoor"], active: true},
  %{name: "Running Shoes Pro", sku: "SPRT-004", price: Decimal.new("129.99"),
    cost: Decimal.new("65.00"), stock_quantity: 150, featured: true,
    category_id: 4, supplier_id: 4, tags: ["fitness", "running"], active: true},
  %{name: "Water Bottle Insulated 32oz", sku: "SPRT-005", price: Decimal.new("24.99"),
    cost: Decimal.new("10.00"), stock_quantity: 300, featured: false,
    category_id: 4, supplier_id: 4, tags: ["hydration", "outdoor"], active: true},

  # Books (category 5, supplier 5)
  %{name: "The Art of Programming", sku: "BOOK-001", price: Decimal.new("49.99"),
    cost: Decimal.new("25.00"), stock_quantity: 100, featured: true,
    category_id: 5, supplier_id: 5, tags: ["technology", "education"], active: true},
  %{name: "Modern Business Strategy", sku: "BOOK-002", price: Decimal.new("34.99"),
    cost: Decimal.new("18.00"), stock_quantity: 80, featured: false,
    category_id: 5, supplier_id: 5, tags: ["business", "education"], active: true},
  %{name: "Cooking Masterclass Cookbook", sku: "BOOK-003", price: Decimal.new("29.99"),
    cost: Decimal.new("15.00"), stock_quantity: 120, featured: false,
    category_id: 5, supplier_id: 5, tags: ["cooking", "lifestyle"], active: true},
  %{name: "Fitness & Nutrition Guide", sku: "BOOK-004", price: Decimal.new("24.99"),
    cost: Decimal.new("12.00"), stock_quantity: 150, featured: false,
    category_id: 5, supplier_id: 5, tags: ["health", "fitness"], active: true},
  %{name: "Travel Photography Guide", sku: "BOOK-005", price: Decimal.new("39.99"),
    cost: Decimal.new("20.00"), stock_quantity: 90, featured: true,
    category_id: 5, supplier_id: 5, tags: ["photography", "travel"], active: true},

  # Accessories (category 6, supplier 6)
  %{name: "Leather Wallet Slim", sku: "ACCS-001", price: Decimal.new("44.99"),
    cost: Decimal.new("20.00"), stock_quantity: 200, featured: false,
    category_id: 6, supplier_id: 6, tags: ["leather", "everyday"], active: true},
  %{name: "Sunglasses Polarized", sku: "ACCS-002", price: Decimal.new("79.99"),
    cost: Decimal.new("35.00"), stock_quantity: 150, featured: true,
    category_id: 6, supplier_id: 6, tags: ["eyewear", "outdoor"], active: true},
  %{name: "Watch Band Silicone", sku: "ACCS-003", price: Decimal.new("19.99"),
    cost: Decimal.new("8.00"), stock_quantity: 300, featured: false,
    category_id: 6, supplier_id: 6, tags: ["wearable", "replacement"], active: true},
  %{name: "Phone Case Premium", sku: "ACCS-004", price: Decimal.new("29.99"),
    cost: Decimal.new("12.00"), stock_quantity: 400, featured: false,
    category_id: 6, supplier_id: 6, tags: ["mobile", "protection"], active: true},
  %{name: "Laptop Sleeve 15-inch", sku: "ACCS-005", price: Decimal.new("34.99"),
    cost: Decimal.new("15.00"), stock_quantity: 180, featured: false,
    category_id: 6, supplier_id: 6, tags: ["computer", "protection"], active: true},

  # Additional products for variety
  %{name: "Organic Green Tea Set", sku: "FOOD-001", price: Decimal.new("24.99"),
    cost: Decimal.new("12.00"), stock_quantity: 200, featured: false,
    category_id: 7, supplier_id: 7, tags: ["organic", "beverage"], active: true},
  %{name: "Premium Coffee Beans 1lb", sku: "FOOD-002", price: Decimal.new("19.99"),
    cost: Decimal.new("10.00"), stock_quantity: 300, featured: true,
    category_id: 7, supplier_id: 7, tags: ["coffee", "beverage"], active: true},
  %{name: "Natural Face Moisturizer", sku: "HLTH-001", price: Decimal.new("34.99"),
    cost: Decimal.new("15.00"), stock_quantity: 150, featured: false,
    category_id: 8, supplier_id: 8, tags: ["skincare", "natural"], active: true},
  %{name: "Vitamin D Supplements", sku: "HLTH-002", price: Decimal.new("19.99"),
    cost: Decimal.new("8.00"), stock_quantity: 250, featured: false,
    category_id: 8, supplier_id: 8, tags: ["supplements", "health"], active: true},
  %{name: "Essential Oil Diffuser", sku: "HLTH-003", price: Decimal.new("49.99"),
    cost: Decimal.new("25.00"), stock_quantity: 100, featured: true,
    category_id: 8, supplier_id: 8, tags: ["aromatherapy", "wellness"], active: true}
]

products = Enum.map(products_data, fn attrs ->
  {:ok, product} = %Product{} |> Product.changeset(attrs) |> Repo.insert()
  product
end)

# Link some products to tags
IO.puts("Linking products to tags...")

product_tag_links = [
  {1, 1}, {1, 3},  # Headphones: Featured, Best Seller
  {2, 1}, {2, 5},  # Smart Watch: Featured, Premium
  {7, 2}, {7, 4},  # Slim Fit Jeans: New Arrival, On Sale
  {8, 1}, {8, 5},  # Winter Jacket: Featured, Premium
  {11, 1}, {11, 5}, # Cookware Set: Featured, Premium
  {16, 1}, {16, 6}, # Yoga Mat: Featured, Eco-Friendly
  {17, 1}, {17, 5}, # Dumbbells: Featured, Premium
  {21, 1}, {21, 8}, # Art of Programming: Featured, Gift Idea
  {27, 4}, {27, 8}, # Sunglasses: On Sale, Gift Idea
  {32, 6}, {32, 2}  # Coffee Beans: Eco-Friendly, New Arrival
]

Enum.each(product_tag_links, fn {product_id, tag_id} ->
  Repo.query!("INSERT INTO product_tags (product_id, tag_id) VALUES ($1, $2)", [product_id, tag_id])
end)

IO.puts("Creating customers...")

customers_data = [
  %{name: "Alice Johnson", email: "alice.johnson@email.com", phone: "555-1001",
    tier: "vip", company_name: "Johnson Enterprises", city: "New York", country: "USA",
    active: true, verified_at: DateTime.utc_now()},
  %{name: "Bob Smith", email: "bob.smith@email.com", phone: "555-1002",
    tier: "premium", city: "Los Angeles", country: "USA",
    active: true, verified_at: DateTime.utc_now()},
  %{name: "Carol Williams", email: "carol.williams@email.com", phone: "555-1003",
    tier: "standard", city: "Chicago", country: "USA", active: true},
  %{name: "David Brown", email: "david.brown@email.com", phone: "555-1004",
    tier: "premium", company_name: "Brown & Co", city: "Houston", country: "USA",
    active: true, verified_at: DateTime.utc_now()},
  %{name: "Eva Martinez", email: "eva.martinez@email.com", phone: "555-1005",
    tier: "vip", city: "Phoenix", country: "USA",
    active: true, verified_at: DateTime.utc_now()},
  %{name: "Frank Miller", email: "frank.miller@email.com", phone: "555-1006",
    tier: "standard", city: "Philadelphia", country: "USA", active: true},
  %{name: "Grace Lee", email: "grace.lee@email.com", phone: "555-1007",
    tier: "premium", city: "San Antonio", country: "USA", active: true},
  %{name: "Henry Wilson", email: "henry.wilson@email.com", phone: "555-1008",
    tier: "standard", city: "San Diego", country: "USA", active: true},
  %{name: "Iris Chen", email: "iris.chen@email.com", phone: "555-1009",
    tier: "vip", company_name: "Chen Industries", city: "Dallas", country: "USA",
    active: true, verified_at: DateTime.utc_now()},
  %{name: "Jack Taylor", email: "jack.taylor@email.com", phone: "555-1010",
    tier: "standard", city: "San Jose", country: "USA", active: false},
  %{name: "Karen White", email: "karen.white@email.com", phone: "555-1011",
    tier: "premium", city: "Austin", country: "USA", active: true},
  %{name: "Leo Garcia", email: "leo.garcia@email.com", phone: "555-1012",
    tier: "standard", city: "Jacksonville", country: "USA", active: true},
  %{name: "Maria Rodriguez", email: "maria.rodriguez@email.com", phone: "555-1013",
    tier: "vip", city: "San Francisco", country: "USA",
    active: true, verified_at: DateTime.utc_now()},
  %{name: "Nathan Kim", email: "nathan.kim@email.com", phone: "555-1014",
    tier: "premium", city: "Columbus", country: "USA", active: true},
  %{name: "Olivia Davis", email: "olivia.davis@email.com", phone: "555-1015",
    tier: "standard", city: "Fort Worth", country: "USA", active: true}
]

customers = Enum.map(customers_data, fn attrs ->
  {:ok, customer} = %Customer{} |> Customer.changeset(attrs) |> Repo.insert()
  customer
end)

IO.puts("Creating employees...")

# Create CEO first (no manager)
{:ok, ceo} = %Employee{}
|> Employee.changeset(%{
  first_name: "James", last_name: "Wilson", email: "james.wilson@company.com",
  title: "CEO", department: "Executive", hire_date: ~D[2015-01-15],
  salary: Decimal.new("250000.00"), active: true
})
|> Repo.insert()

# Create VPs (report to CEO)
{:ok, vp_sales} = %Employee{}
|> Employee.changeset(%{
  first_name: "Sarah", last_name: "Connor", email: "sarah.connor@company.com",
  title: "VP of Sales", department: "Sales", hire_date: ~D[2016-03-01],
  salary: Decimal.new("180000.00"), active: true, manager_id: ceo.id
})
|> Repo.insert()

{:ok, vp_eng} = %Employee{}
|> Employee.changeset(%{
  first_name: "Michael", last_name: "Scott", email: "michael.scott@company.com",
  title: "VP of Engineering", department: "Engineering", hire_date: ~D[2016-06-15],
  salary: Decimal.new("185000.00"), active: true, manager_id: ceo.id
})
|> Repo.insert()

{:ok, vp_hr} = %Employee{}
|> Employee.changeset(%{
  first_name: "Linda", last_name: "Park", email: "linda.park@company.com",
  title: "VP of HR", department: "Human Resources", hire_date: ~D[2017-01-10],
  salary: Decimal.new("150000.00"), active: true, manager_id: ceo.id
})
|> Repo.insert()

# Create Managers (report to VPs)
{:ok, sales_mgr1} = %Employee{}
|> Employee.changeset(%{
  first_name: "Tom", last_name: "Hardy", email: "tom.hardy@company.com",
  title: "Sales Manager", department: "Sales", hire_date: ~D[2018-02-20],
  salary: Decimal.new("95000.00"), active: true, manager_id: vp_sales.id
})
|> Repo.insert()

{:ok, sales_mgr2} = %Employee{}
|> Employee.changeset(%{
  first_name: "Jennifer", last_name: "Lopez", email: "jennifer.lopez@company.com",
  title: "Sales Manager", department: "Sales", hire_date: ~D[2018-05-15],
  salary: Decimal.new("92000.00"), active: true, manager_id: vp_sales.id
})
|> Repo.insert()

{:ok, eng_mgr} = %Employee{}
|> Employee.changeset(%{
  first_name: "Robert", last_name: "Chen", email: "robert.chen@company.com",
  title: "Engineering Manager", department: "Engineering", hire_date: ~D[2017-08-01],
  salary: Decimal.new("130000.00"), active: true, manager_id: vp_eng.id
})
|> Repo.insert()

# Create individual contributors
employees_ic = [
  %{first_name: "Alex", last_name: "Turner", email: "alex.turner@company.com",
    title: "Sales Rep", department: "Sales", hire_date: ~D[2019-03-10],
    salary: Decimal.new("65000.00"), manager_id: sales_mgr1.id},
  %{first_name: "Betty", last_name: "White", email: "betty.white@company.com",
    title: "Sales Rep", department: "Sales", hire_date: ~D[2019-06-20],
    salary: Decimal.new("62000.00"), manager_id: sales_mgr1.id},
  %{first_name: "Chris", last_name: "Evans", email: "chris.evans@company.com",
    title: "Sales Rep", department: "Sales", hire_date: ~D[2020-01-15],
    salary: Decimal.new("60000.00"), manager_id: sales_mgr2.id},
  %{first_name: "Diana", last_name: "Ross", email: "diana.ross@company.com",
    title: "Senior Software Engineer", department: "Engineering", hire_date: ~D[2018-04-01],
    salary: Decimal.new("145000.00"), manager_id: eng_mgr.id},
  %{first_name: "Eric", last_name: "Johnson", email: "eric.johnson@company.com",
    title: "Software Engineer", department: "Engineering", hire_date: ~D[2019-09-15],
    salary: Decimal.new("110000.00"), manager_id: eng_mgr.id},
  %{first_name: "Fiona", last_name: "Apple", email: "fiona.apple@company.com",
    title: "Software Engineer", department: "Engineering", hire_date: ~D[2020-03-01],
    salary: Decimal.new("105000.00"), manager_id: eng_mgr.id},
  %{first_name: "George", last_name: "Martin", email: "george.martin@company.com",
    title: "HR Specialist", department: "Human Resources", hire_date: ~D[2019-07-01],
    salary: Decimal.new("72000.00"), manager_id: vp_hr.id},
  %{first_name: "Hannah", last_name: "Baker", email: "hannah.baker@company.com",
    title: "HR Coordinator", department: "Human Resources", hire_date: ~D[2020-02-15],
    salary: Decimal.new("55000.00"), manager_id: vp_hr.id}
]

Enum.each(employees_ic, fn attrs ->
  %Employee{} |> Employee.changeset(Map.put(attrs, :active, true)) |> Repo.insert!()
end)

IO.puts("Creating orders...")

# Generate orders for the past year
statuses = ["pending", "processing", "shipped", "delivered", "cancelled"]
status_weights = [10, 15, 20, 50, 5]  # More delivered orders

defmodule SeedHelpers do
  def weighted_random(items, weights) do
    total = Enum.sum(weights)
    r = :rand.uniform(total)

    {_, _, item} = Enum.zip([items, weights])
    |> Enum.reduce({0, r, nil}, fn {item, weight}, {acc, remaining, _selected} ->
      new_acc = acc + weight
      if remaining <= new_acc and remaining > acc do
        {new_acc, remaining, item}
      else
        {new_acc, remaining, nil}
      end
    end)

    item || List.last(items)
  end
end

# Create orders
orders_data = for i <- 1..200 do
  customer = Enum.random(customers)
  days_ago = :rand.uniform(365)
  order_date = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.add(-days_ago * 24 * 60 * 60, :second)
  status = SeedHelpers.weighted_random(statuses, status_weights)

  shipped_at = if status in ["shipped", "delivered"] do
    DateTime.add(DateTime.utc_now(), (-days_ago + :rand.uniform(3)) * 24 * 60 * 60, :second)
  else
    nil
  end

  delivered_at = if status == "delivered" do
    DateTime.add(shipped_at || DateTime.utc_now(), :rand.uniform(5) * 24 * 60 * 60, :second)
  else
    nil
  end

  %{
    order_number: "ORD-#{String.pad_leading(Integer.to_string(i), 6, "0")}",
    status: status,
    subtotal: Decimal.new("0"),  # Will be calculated
    tax: Decimal.new("0"),
    shipping: Decimal.new("9.99"),
    discount: if(:rand.uniform(10) > 7, do: Decimal.new("10.00"), else: Decimal.new("0")),
    total: Decimal.new("0"),  # Will be calculated
    shipping_city: customer.city,
    shipping_country: customer.country,
    customer_id: customer.id,
    shipped_at: shipped_at,
    delivered_at: delivered_at,
    inserted_at: order_date,
    updated_at: order_date
  }
end

orders = Enum.map(orders_data, fn attrs ->
  {:ok, order} = %Order{}
  |> Ecto.Changeset.change(attrs)
  |> Ecto.Changeset.validate_required([:order_number, :customer_id])
  |> Repo.insert()
  order
end)

IO.puts("Creating order items...")

# Add items to each order
Enum.each(orders, fn order ->
  num_items = :rand.uniform(5)  # 1-5 items per order
  selected_products = Enum.take_random(products, num_items)

  {subtotal, _line_num} = Enum.reduce(selected_products, {Decimal.new("0"), 1}, fn product, {acc, line_num} ->
    quantity = :rand.uniform(3)
    discount = if :rand.uniform(10) > 8, do: Decimal.mult(product.price, Decimal.new("0.1")), else: Decimal.new("0")
    line_total = Decimal.sub(
      Decimal.mult(product.price, Decimal.new(quantity)),
      Decimal.mult(discount, Decimal.new(quantity))
    )

    %OrderItem{}
    |> OrderItem.changeset(%{
      quantity: quantity,
      unit_price: product.price,
      discount: discount,
      line_total: line_total,
      line_number: line_num,
      order_id: order.id,
      product_id: product.id
    })
    |> Repo.insert!()

    {Decimal.add(acc, line_total), line_num + 1}
  end)

  # Update order totals
  tax = Decimal.mult(subtotal, Decimal.new("0.08")) |> Decimal.round(2)
  total = subtotal
  |> Decimal.add(tax)
  |> Decimal.add(order.shipping)
  |> Decimal.sub(order.discount)

  order
  |> Ecto.Changeset.change(%{subtotal: subtotal, tax: tax, total: total})
  |> Repo.update!()
end)

IO.puts("Creating reviews...")

# Add reviews from customers who have orders
Enum.each(1..100, fn _ ->
  customer = Enum.random(customers)
  product = Enum.random(products)

  # Check if review already exists
  existing = Repo.get_by(Review, product_id: product.id, customer_id: customer.id)

  if is_nil(existing) do
    %Review{}
    |> Review.changeset(%{
      rating: :rand.uniform(5),
      title: Enum.random(["Great product!", "Good value", "As expected", "Could be better", "Excellent!"]),
      body: "This is my review of the #{product.name}. " <>
            Enum.random(["Highly recommend.", "Works as advertised.", "Fast shipping.", "Would buy again."]),
      helpful_count: :rand.uniform(50) - 1,
      verified_purchase: :rand.uniform(10) > 3,
      product_id: product.id,
      customer_id: customer.id
    })
    |> Repo.insert()
  end
end)

IO.puts("Seed completed!")

# Print summary
IO.puts("\nDatabase Summary:")
IO.puts("  Categories: #{Repo.aggregate(Category, :count)}")
IO.puts("  Suppliers: #{Repo.aggregate(Supplier, :count)}")
IO.puts("  Products: #{Repo.aggregate(Product, :count)}")
IO.puts("  Tags: #{Repo.aggregate(Tag, :count)}")
IO.puts("  Customers: #{Repo.aggregate(Customer, :count)}")
IO.puts("  Employees: #{Repo.aggregate(Employee, :count)}")
IO.puts("  Orders: #{Repo.aggregate(Order, :count)}")
IO.puts("  Order Items: #{Repo.aggregate(OrderItem, :count)}")
IO.puts("  Reviews: #{Repo.aggregate(Review, :count)}")
