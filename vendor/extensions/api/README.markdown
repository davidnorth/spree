Spree API
=========
Manage orders,shipments etc. with a simple REST API


General Usage
=============

## Making requests

You will need an api key to authenticate. These can be generated on the user edit screen within the admin interface.
Your requests should include this key in the X-SpreeAPIKey header e.g.

    curl -H "Content-Type:application/json" -H "Accept:application/json" -H "X-SpreeAPIKey: YOUR_KEY" http://example.com/api/orders

## HTTP Methods

Your requests must use the correct HTTP method.

* GET for listing and viewing individual records
* POST for creating records
* PUT for updating existing records
* DELETE for deleting records

## Searching

All list actions support filtering using search logic parameters. 
For example, to view all shipments that are ready to ship and that were created since the date 2009-01-01:

/api/shipments?search[state]=ready_to_ship&search[created_at_greater_than]=2010-01-01

For more details, see http://github.com/binarylogic/searchlogic

## Creating and updating resources

Parameters should be supplied in the request body as a JSON encoded hash of attributes.

Sucessfully creating a resource will result in a 201 (Created) response code while updating will result in 200 (OK).
If creating or updating a resource fails the result will be a 422 (Unprocessable Entity) response and a list of errors e.g.

    {"errors": ["First Name can't be blank","Last Name can't be blank"}



Orders
======

## List orders - GET /api/orders

### Response

    [
      { order: { ... } },
      { order: { ... } },
      ...
    ]


## View order - GET /api/orders/{order_id}

### Response

    {
      order: {
        ...
      }
    }

## Line items for an order - GET /api/orders/{order_id}/line_items

### Response

    [
      { line_item: { ... } },
      { line_item: { ... } },
      ...
    ]


## Create a line item on an order - POST /api/orders/{order_id}/line_items

### Request

    ...

### Response

    HTTP Status: 201 Created
    Location: http://example.com/api/orders/{order_id}/line_items/{new_line_item_id}

## Update a line item - PUT /api/orders/{order_id}/line_items/{line_item_id}

### Request

    ...

### Response

    HTTP Status: 200 OK

## Shipments for an order - GET /api/orders/{order_id}/shipments

### Response

    [
      { shipment: { ... } },
      { shipment: { ... } },
      ...
    ]

## Create a shipment for an order - POST /api/orders/{order_id}/shipments

### Request

    ...

### Response

    HTTP Status: 201 Created
    Location: http://example.com/api/orders/{order_id}/shipments/{new_shipment_id}

## Fire state event - PUT /api/orders/{order_id}/event?e={event_name}

### Response (success)

    HTTP Status: 200 OK

### Response (Failure)

    HTTP Status: 422


Shipments
=========

## List shipments - GET /api/shipments

### Response

    [
      { shipment: { ... } },
      { shipment: { ... } },
      ...
    ]

## View shipment - GET /api/shipments/{shipment_id}

### Response

    {
      shipment: { ... }
    }

## Update shipment - PUT /api/shipments/{shipment_id}

### Request

    ...

### Response

    HTTP Status: 200 OK

## Fire state event - PUT /api/shipments/{shipment_id}/event?e={shipment_id}

### Response (success)

    HTTP Status: 200 OK

### Response (Failure)

    HTTP Status: 422


