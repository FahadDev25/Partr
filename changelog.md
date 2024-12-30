# Changelog
Major changes should be recorded here

## Unreleased

## v0.6.10

### Added
- page to autoprint unprinted order attachments (teams/:id/auto\_print\_orders)
- button on orders page to directly create part received
- admin page (/pages/admin) with changelog and autoprint count
- set user on shipment/part received creation

### Changed
- unfilter order vendor select list when manual line items enabled
- use created_at date for po pdfs
- hide jobs with closed status from order job select list, and remove create order button from jobs with closed status
- allow any content type for attachments
- made qr code labels smaller
- made part recieved form more convenient for shipments for manual orders
- store received quantity in line items and orders for faster loading
- redirect logged in users to team home when visiting the home page

### Fixed
- component form correctly autofills assembly
- validate line item discounts

---
## Released

## v0.6.9

### Added
- extra buttons on part quantity fields to increment/decrement by 0
- store job project manager, status and order created by filters in session store
- pin jobs to home
- job default tax rate
- order needs reimbursement email
- weekly additional parts update email

### Changed
- changed part quantities to
- order job, order, recent order tables and job select list by date_created
- add job name to job select list
- when a part is added the part table is updated without removing the modal
- order payment type is now tom-select with ability to either create new or select from previously used payment types

### Fixed
- subassembly circular relation validation recursively checks all child subassemblies, instead of just one branch
- added placeholder text for link to shipment when shipment number blank
- non admin users no longer locked out of team switching
- tom-select shows all options in the dropdown, instead of default limit of 50

## v0.6.8

### Added
- shared parts table (moved to shared records)
- tom-select for multiple select and searchable select
- shared records table for sharing jobs/orders/shipments/assemblies
- rack-attack for throttling/blocking requests
- team roles with permissiond (create/destroy jobs, access all jobs/orders/shipments)
- auto incrementing job numbers based on prefix
- organization job number prefix

### Changed
- filter parts index to current team
- made org part number read-only for non-admin users
- populate order parts list with all parts if job has no parts

### Fixed
- authenticate_user! no longer happens before error page controller actions, causing a warden error
- Team members form selects the correct team

## v0.6.7 - 2024-7-26

### Added
- order option to mark line items received at creation
- cross team order/job/shipment search
- expected delivery date for line items
- include in BOM option for orders in manual line item enabled teams, display BOM on jobs with orders where include in bom is true
- addresses table
- organization, team, order billing address
- organization fax number
- line_item SKU


### Changed
- made created by column on orders visible to all users, not just admins
- removed external url helper, validate urls
- address columns on models changed to references to address table
- refresh devise rememberable when remembered through cookie

### Fixed
- line item discount correctly subtracted in po export

## v0.6.6 - 2024-7-17

### Added

### Changed
- job status changed to select
- hide closed jobs by default
- autofill order date
- wrap attachment filenames

### Fixed
- export button on individual order pages shows job name/number options

## v0.6.5 - 2024-7-12

### Added
- address fields for jobs, orders

### Changed
- shorter PO filenames

## v0.6.4 - 2024-7-11

### Added
- enabled devise recoverable to send password reset emails
- enabled devise lockable to lock account after a number of failed login attempts

### Changed
- changed cert number 1 and 2 to optional part field 1 and 2

## v0.6.3 - 2024-7-8

### Added
- price staleness team options
- default tax rate team option
- po export automationdirect format
- user po prefix setting
- email order creator on shipment creation
- job number for jobs
- po/job attachments
- manual po line item entry
- order payment confirmation column
- RFQ option for order export
- link to display changelog

### Changed
- resize packing slips before saving
- sign in with email instead of username
- switched to sendgrid to send emails in staging/production
- display po total cost along with job cost
- don't require order date, only mark parts ordered when order date is passed
- order export options moved from table to form
- filter order only by team instead of team and user

### Fixed
- job create order link works again
- job unit parts display the correct quantity
- parts received part select dropdown only shows parts from the order
- enable notice on 2fa page
- bind redis to container

## v0.6.2 - 2024-6-19

### Added
- landing screen
- csv export/import for Manufacturers, Vendors, Customers, Parts
- job ordered parts tracking
- order received parts tracking
- universal option for vendors to allow them to be added to any order
- cert, username, password for mcmaster-carr api
- payment method for orders
- team cert number options
- part price last updated
- price history for parts
- comments (currently on jobs, orders, shipments)

### Changed
- index pages are now search/filter/sortable paginated tables
- new/edit changed to modals for most models
- combined order and assembly export buttons
- job parts and vendor lists look at other part numbers
- costs go out to 4 decimal places
- date_paid and amount_paid columns for orders
- second address line for models with addresses
- phone numbers switched to strings and use input masks in forms
- hide devise links
- seperate cost per unit for line items
- attach links to mfg part numbers, other part numbers
- part labels in po change depending on vendor
- added description column to assembly components table
- made nested routes shallow

## v0.6.1 - 2024-5-9

### Added
- OtherPartNumbers model to hold different part numbers from customers/vendors/manufacturers
- Two factor authentication through devise-two-factor
- Subassemblies: allows adding assemblies to assemblies

### Changed
- Added address and phone number attributes to organizations/teams
- Added logo to organizations
- Changed panel table/controller names to assembly
- Added default unit and  assembly label to teams

## v0.6.0 - 2024-4-12

### Added
- Multitenancy with the Acts as Tenant gem
  - scopes most models to new organization model
- Teams model to separate jobs, orders and shipments (id added to others)
- Packing slip images for shipments
- Add parts directly to jobs
  - add these parts to orders/shipments
- Support for modals with UltimateTurboModal
- fill job parts from inventory
- edit part inventory through modal
- part index search, filter, sort and pagination
- part qr codes

### Changed
- Signup user with organization and team
- Owners and admins can invite users instead of create
- PO pdf new format
- can create order with only cost totals
- part mismatch email table given more space
- part new, show, and edit pages are now modals
- pdf generation with ferrum instead of grover

### Fixed
- github actions actually uses the cache for build and push
- creating a pdf or csv for an order with no vendor no longer breaks
- fixed part mismatch email not being sent for units when some of the parts were filled from inventory

## v0.5.0 - 2023-11-6

### Added
- changelog.md
- users: Admins can create/edit, regular users can edit themselves. Sign in required

### Changed

### Fixed
- hopefully github actions will use the cache for the build and push action