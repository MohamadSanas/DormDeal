# STEP-BY-STEP GUIDE: HOW TO RUN DORMDEAL & CAPTURE ALL REPORT SCREENSHOTS

This guide gives you the exact commands and actions to run both the Backend and Flutter Frontend, generate realistic mock data, and capture high-resolution screenshots for your **EC9540 Assignment 02 Report**.

---

## 🚀 STEP 1: Start the Backend Server

Open **Terminal 1** (PowerShell) in your project directory:

```powershell
cd "c:\Users\sanas\Desktop\my learn\Projects\DormDeal\backend"
.\venv\Scripts\activate
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

> **Verify:** Open your browser and go to `http://localhost:8000/docs`. You will see the interactive Swagger UI.

---

## 📱 STEP 2: Run the Flutter Application

Open **Terminal 2** in your project directory:

### Option A: Run on Android Emulator or Physical Android Phone (Best for realistic mobile look)
```powershell
cd "c:\Users\sanas\Desktop\my learn\Projects\DormDeal\DormDeal"
flutter run
```

### Option B: Run on Chrome Browser or Windows Desktop (Quickest if no phone/emulator connected)
```powershell
cd "c:\Users\sanas\Desktop\my learn\Projects\DormDeal\DormDeal"
flutter run -d chrome
# OR
flutter run -d windows
```

---

## 📸 STEP 3: Taking & Saving Screenshots (Windows Shortcuts)

- **On Windows:** Press **`Windows Key + Shift + S`** to open the Snipping Tool. Drag a rectangle over the app screen, then paste (`Ctrl + V`) directly into your Word / Google Doc report or save to a `screenshots/` folder.
- **On Android Emulator:** Click the **Camera Icon** on the right emulator sidebar. Screenshots are automatically saved to your desktop.
- **On Physical Android Phone:** Press **`Power Button + Volume Down`**.

---

## 📋 STEP 4: Exact Screenshots Checklist & How to Capture Each

| Figure # | Screen Name | Code File | What to Do & Capture |
| :--- | :--- | :--- | :--- |
| **Figure 1** | **Sign In (Login)** | `login_screen.dart` | 1. Open the app.<br>2. Fill in an email (e.g. `student@eng.jfn.ac.lk`) and password.<br>3. Capture the login screen showing the clean branding and input fields. |
| **Figure 2** | **Sign Up (Registration)** | `signup_screen.dart` | 1. Tap "Sign Up" on the login screen.<br>2. Fill in Name ("Kasun Perera"), University ("Faculty of Engineering"), Email, WhatsApp Number.<br>3. Capture the registration form. |
| **Figure 3** | **Marketplace Home Feed** | `home_screen.dart` | 1. Log in to reach the main home feed.<br>2. Make sure items are visible in the grid (e.g., Pedestal Fan, Engineering Mathematics Book, Desk Lamp).<br>3. Capture the screen showing the category pills (*Textbooks, Electronics, etc.*) and item cards with countdown badges. |
| **Figure 4** | **Instant Keyword Search** | `home_screen.dart` | 1. Tap on the search bar at the top.<br>2. Type `fan` or `book`.<br>3. Capture the screen showing the instant filtered results matching the keyword. |
| **Figure 5** | **Item Details & Live Timer** | `item_detail_screen.dart` | 1. Tap on any item card (e.g., "3-Speed Pedestal Fan").<br>2. Capture the screen showing the photo carousel, Starting Price vs Current Highest Bid, seller WhatsApp button, and the **live countdown timer** (`XXh XXm XXs`). |
| **Figure 6** | **Place Bid Modal Sheet** | `place_bid_screen.dart` | 1. On the Item Detail screen, tap the big blue **"Place Bid"** button.<br>2. Tap one of the quick increment chips (e.g., `+Rs. 100`).<br>3. Capture the bottom sheet displaying minimum bid calculation, increment chips, and confirmation button. |
| **Figure 7** | **Post New Auction Listing** | `post_item_screen.dart` | 1. On Home screen, tap the blue `+` Floating Action Button.<br>2. Select an image, fill in Title ("Rechargeable Desk Fan"), Category ("Electronics"), Condition ("Good"), Duration ("3 Days"), and Price ("Rs. 2,500").<br>3. Capture the filled form before tapping Publish. |
| **Figure 8** | **Seller "My Listings"** | `my_listings_screen.dart` | 1. Tap the 4th tab on the bottom navigation ("My Listings").<br>2. Capture the screen showing your posted items with status badges ("Active", "2 Bids", current price). |
| **Figure 9** | **Seller Item Inspection & WhatsApp** | `view_listed_item_screen.dart` | 1. Tap on one of your items from "My Listings".<br>2. Capture the screen showing the highest bidder details (Name, Bid Amount) and the green **"Contact on WhatsApp"** button. |
| **Figure 10** | **Buyer "My Bids" Tracking** | `my_bids_screen.dart` | 1. Tap the 2nd tab on the bottom navigation ("My Bids").<br>2. Capture the screen showing the items you have bid on, displaying the green **"Winning"** badge or red **"Outbid"** badge. |
| **Figure 11** | **Alerts & Notification Feed** | `alerts_screen.dart` | 1. Tap the 3rd tab on the bottom navigation ("Alerts").<br>2. Capture the notifications list showing alerts such as *"You have been outbid on..."* or *"New bid received on your item"*. |
| **Figure 12** | **Profile & Campus Credentials** | `profile_screen.dart` | 1. Tap the 5th tab on the bottom navigation ("Profile").<br>2. Capture the profile card showing student name, university tag, active listing counters, and logout button. |
| **Figure 13** | **FastAPI Swagger API Docs** | Backend Web | 1. Open `http://localhost:8000/docs` in Google Chrome.<br>2. Expand routes `/api/v1/items/` and `/api/v1/bids/`.<br>3. Capture the browser window proving backend API implementation. |
| **Figure 14** | **Neon Cloud PostgreSQL DB** | Cloud Console | 1. Open `https://console.neon.tech` (or pgAdmin/DBeaver).<br>2. Show the `items` and `bids` tables with real records.<br>3. Capture the table view proving cloud persistence. |

---

## 💡 Evaluation Tips to Get Maximum Marks

1. **Highlight the HCI Principles:**
   - When the lecturer asks why you chose certain designs, explain:
     - **Cognitive Load:** 6 category chips prevent choice overload (Hick's Law).
     - **Fitts' Law:** Large 52dp full-width buttons for "Place Bid" and "WhatsApp" are easy to hit with the thumb.
     - **Visibility of System Status:** Live countdown timers and "Winning / Outbid" color badges keep users aware of real-time state.
2. **Demonstrate Peer-to-Peer Trust:**
   - Mention that students don't like dealing with strangers; DormDeal shows the student's campus/faculty and connects directly via WhatsApp so buyers and sellers can meet safely on campus for cash-on-delivery exchange.
3. **Bring a Printed or Digital PDF of the Report:**
   - Use the file `EC9540_Assignment_02_DormDeal_Project_Report.md` generated in your workspace. You can convert it to PDF or Word, insert your captured screenshots into Figures 1 through 14, and present it with confidence!
