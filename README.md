# 🚀 Salesforce CPQ-Lite: Automated Quoting & Discounting System

This repository contains professional-grade Apex developments for a Salesforce Sales Cloud environment. The project focuses on automating the Quote-to-Cash lifecycle and implementing dynamic, category-based discounting logic.

---

## 🌟 Key Features

### 1. Automated Quote Generation
* **Trigger:** `OpportunityTrigger`
* **Functionality:** Automatically generates a new `Quote` record when an Opportunity stage transitions to **'Proposal/Price Quote'**.
* **Smart Logic:** Uses `oldMap` state-tracking to ensure quotes are only created once per stage transition, preventing duplicate records on unrelated updates.

### 2. Intelligent Tiered Discounting Engine
* **Trigger:** `QuoteLineItemTrigger`
* **Functionality:** Implements a dynamic discounting model based on custom `Product_Category__c` settings:
    * **Base Discount:** Default discount for low-volume orders.
    * **Tier 1 & Tier 2:** Automatically escalates discount percentages as Quantity exceeds defined thresholds (e.g., >10 or >50 units).
* **Manual Override:** The engine is built to respect manual rep entries; if a salesperson provides a custom discount, the automation steps back to allow flexibility.

### 3. Business Guardrails & Validations
* **Max Discount Validation:** Prevents data entry errors by blocking any discount that exceeds the `Max_Discount__c` limit defined at the Category level.
* **Approval Notifications:** Automatically posts to the Quote's Chatter feed when a high-value discount (>20%) is applied, alerting the management team for review.

---

## 🏗 Technical Architecture

* **Pattern:** Follows the **Trigger Handler Pattern** for clean, maintainable, and bulkified code.
* **Best Practices:**
    * **Bulkification:** All logic is designed to handle 200+ records in a single DML operation.
    * **Recursive Control:** Logic ensures triggers don't fire unnecessarily.
    * **SOQL Optimization:** Uses Maps and Sets to stay well within Salesforce Governor Limits.

---

## 🧪 Testing & Quality Assurance

Quality is at the core of this project. All components have been verified with comprehensive test suites:
* **Code Coverage:** **100%** achieved across all custom classes.
* **Test Classes Included:**
    * `OpportunityTriggerHandlerTest`: Validates auto-creation workflows.
    * `QuoteDiscountHandlerTest`: Tests all discount tiers, overrides, and validation error messages.
    * `QuoteApprovalHandlerTest`: Verifies Chatter notification logic.

---

