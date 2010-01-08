Spree API
=========
Manage orders,shipments etc. with a simple REST API

General Usage
=============

Making requests
--------------

You will need an api key to authenticate. These can be generated on the user edit screen within the admin interface.
Your requests should include this key in the X-SpreeAPIKey header e.g.

curl -H "Content-Type:application/json" -H "Accept:application/json" -H "X-SpreeAPIKey: YOUR_KEY" http://example.com/api/orders

HTTP Methods
------------
Your requests must use the correct HTTP method.

* GET for listing and viewing individual records
* POST for creating records
* PUT for updating existing records
* DELETE for deleting records

Searching
=========

All list actions support filtering using search logic parameters. 
For example, to view all shipments that are ready to ship and that were created since the date 2009-01-01:

/api/shipments?search[state]=ready_to_ship&search[created_at_greater_than]=2010-01-01

For more details, see http://github.com/binarylogic/searchlogic

Orders
======

List orders
-----------

GET /api/orders

View order
-----------

GET /api/orders/{order_id}

View shipments for an order
---------------------------

GET /api/orders/{order_id}/shipments

Create a shipment for an order
------------------------------

POST /api/orders/{order_id}/shipments


Shipments
=========

List shipments
--------------

GET /api/shipments

View shipment
-------------

GET /api/shipments/{shipment_id_}

