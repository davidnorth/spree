Public Views
============

Layout (layouts/spree_application.html.erb)
------------------------------------------------
* inside_head (allows you to modify content of head tag)
* sidebar (for any pages that have a sidebar)

Homepage (products/index.html.erb)
----------------------------------

* homepage_sidebar_navigation
* homepage_products

Taxon (taxons/show.html.erb)
----------------------------

* taxon_sidebar_navigation
* taxon_products
* taxon_children

View Product (products/show.html.erb products/_taxons.html.erb products/_cart_form.html.erb)
--------------------------------------------------------------------------------------------

* product_description
* product_properties
* product_taxons ('Look for similar items')
* product_price
* inside_product_cart_form

Cart (orders/edit.html.erb)
---------------------------

* inside_cart_form
* cart_items

Checkout (checkouts/edit.html.erb)
----------------------------------

* checkout_singlepage_top (just below page title)
* checkout_singlepage_bottom (after the cart form)

Login (user_sessions/new.html.erb)
----------------------------------

* login

Signup (users/new.html.erb, users/_form.html.erb)
---------------------------

* signup
* signup_inside_form
* signup_below_password_fields (within form, below password confirmation field)

Account (users/show.html.erb)
-----------------------------

* account_top
* account_above_my_orders
* account_below_my_orders

Admin Views
===========

Layout (layouts/admin.html.erb)
-------------------------------

* admin_head (allow scripts etc. to be added to the head tab)

Navigation
----------

The following hooks allow list items to be added to various admin menus

* admin_tabs
* admin_product_sub_tabs
* admin_order_tabs (sidebar menu for individual order)
* admin_product_tabs (sidebar menu for individual product)

