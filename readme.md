<img src="./docs/banner.png" alt="banner" width="100%" />

<br>

> ⚠️ ⚠️ **Notice for ITS Mobile Programming Graders** 
> please make sure that you are referring to ***one of the branches below*** and their respective commits for grading, as the ***main branch includes latest commits*** to the app, ***including updates done after assignment deadline/s.***

- **Section 5, 25 Mar 2025:** `s05`
- **Section 11, 19 May 2025:** `s11`

<br />

## Group 2
| **Name** | **NRP** | **Class** | **Contribution** |
| --- | --- | --- | --- | 
| **Areta Athayayumna Arwaa** | 5025221068 | Mobile Programming (I) | Events CRUD & Solar Times API Setup |
| **Franshel Tranetha** | 5025221083 | Mobile Programming (I) | Firebase Auth Setup & Account Detail CRUD |
| **Taib Izzat Samawi** | 5025221085 | Mobile Programming (I) | Dynamic Calendar, GMaps Integration, Tasks CRUD |

<br />

# `sundial` *(work in progress 🛠️)*
> *an intercogni app*

Manage your daily chores based on solar events.

## 🌟 Feature Development Status 🚧
> ***sundial** will undergo gradual improvements in features. below are the checklist of proposed features of **sundial***

### 🌟 Main Pipeline 🚀
- [x] Firebase Auth
- [x] Firestore Cloud Peristence
- [x] CRUD on tasks based on solar event times
- [x] API call for solar events based on current latitude and longitude
- [x] CRUD on events
- [x] Dynamic Calendar
- [x] GMaps Location API for setting up locations in each date

### APIs to use
- [x] SunriseSunsetTimes.org
- [x] Google Maps Reverse Geolocator
- [x] Google Maps Map Tiling
- [x] Google Maps Reverse Geolocator


## ✨ App Summary


### Demo Video
[Click here to watch the demo video!](https://github.com/intercogni/sundial/blob/s05/docs/demo_video.webm)

<div style="display: flex;">
  <div align="center" style="flex: 1;">
    <h3 align="center">🔑 Login Screen</h3>
    <em align="center">Users can log in to their accounts.</em> <br /> <br />
    <img src="docs/login_screen.png" alt="Login Screen" width="100%">
  </div>
  <div align="center" style="flex: 1;">
    <h3 align="center">📝 Signup Screen</h3>
    <em align="center">New users can create an account.</em> <br /> <br />
    <img src="docs/signup_screen.png" alt="Signup Screen" width="100%">
  </div>
</div>

### A calendar is available on the home page, and the user can set locations they would be in during certain dates via GMaps, and the solar times will change accordingly

<div align="center">
	<h3 align="center">📅 Calendar Before Change</h3>
	<img src="docs/calendar.before_change.png" alt="Calendar Before Change" width="25%">
</div>
<br />
<br />
<br />

<div align="center">
	<h3 align="center">📍 Location Selection</h3>
	<em align="center">Users can select a location for the event.</em> <br /> <br />
	<img src="docs/location1.search.png" alt="Location Search" width="25%">
	<img src="docs/location2.click_details_page.png" alt="Location Details Page" width="25%">
	<img src="docs/location3.details_setup.png" alt="Location Details Setup" width="25%">
	<img src="docs/location4.save.png" alt="Location Save" width="25%">
</div>
<br />
<br />
<br />

<div align="center">
	<h3 align="center">📅 Calendar After Change</h3>
	<img src="docs/calendar.after_date_change1.png" alt="Calendar After Date Change 1" width="25%">
	<img src="docs/calendar.after_date_change2.png" alt="Calendar After Date Change 2" width="25%">
</div>
<br />
<br />
<br />

<!--  TASK SECTION -->
<div align="center">
	<h3 align="center">🏠 Tasks Screen</h3>
	<em align="center">✨ This is the main screen displaying all tasks ✨</em> <br /> <br />
	<img src="docs/tasks_screen.png" alt="Tasks Screen" width="25%">
</div>
<br />
<br />
<br />
<div style="display: flex;">
  <div align="center" style="flex: 1;">
    <h3 align="center">➕ Add Fixed Task</h3>
    <em align="center">✨ Users can add tasks based on what time it occurs ✨</em> <br /> <br />
    <img src="docs/add_fixed_task.png" alt="Add Fixed Task" width="100%">
  </div>
  <div align="center" style="flex: 1;">
    <h3 align="center">📝 Details of Fixed Task</h3>
    <em align="center">Users can view and edit details of a fixed task.</em> <br /> <br />
    <img src="docs/details.add_fixed_task.png" alt="Details Fixed Task" width="100%">
  </div>
  <div align="center" style="flex: 1;">
    <h3 align="center">✅ Results of Adding Fixed Task</h3>
    <em align="center">The fixed task is now added to the list.</em> <br /> <br />
    <img src="docs/results.add_fixed_task.png" alt="Results Add Fixed Task" width="100%">
  </div>
</div>
<br />
<br />
<br />
<div style="display: flex;">
  <div align="center" style="flex: 1;">
    <h3 align="center">➕ Add Relative Task</h3>
    <em align="center">✨ Users can add tasks based on how many minutes before/after sunrise or sunset! ✨</em> <br /> <br />
    <img src="docs/add_relative_task.png" alt="Add Relative Task" width="100%">
  </div>
  <div align="center" style="flex: 1;">
    <h3 align="center">✅ Results of Adding Relative Task</h3>
    <em align="center">✨ The task is now visible in the list ✨</em> <br /> <br />
    <img src="docs/results.add_relative_task.png" alt="Results Add Relative Task" width="100%">
  </div>
</div>
<br />
<br />
<br />


<!--  EVENT SECTION -->
<div align="center">
	<h3 align="center">📅 Events List</h3>
	<em align="center"> Users can view all scheduled duration events </em> <br /> <br />
	<img src="docs/event_list.png" alt="Events List" width="25%">
</div>
<br />
<br />
<br />
<div align="center">
	<h3 align="center">➕ Add New Event</h3>
	<em align="center"> Users can create new event</em> <br /> <br />
	<img src="docs/add_event.png" alt="Add New Event" width="25%">
</div>
<br />
<br />
<br />
<div align="center">
	<h3 align="center">📝 Edit Event</h3>
	<em align="center">Edit and update the details of the event</em> <br /> <br />
	<img src="docs/edit_event.png" alt="Edit Event" width="25%">
</div>
<br />
<br />
<br />
<div align="center">
	<h3 align="center">🕘 Pick Event Duration</h3>
	<em align="center">Setting the start-end date and time of the event</em> <br /> <br />
	<img src="docs/select_event_date.png" alt="Pick Date" width="25%"> <br /> <br />
	<img src="docs/select_event_time.png" alt="Pick Time" width="25%">
</div>
<br />
<br />
<br />
<div align="center">
	<h3 align="center">🗑️ Delete Event</h3>
	<em align="center">Remove an event via the menu on the event card</em> <br /> <br />
	<img src="docs/delete_event.png" alt="Delete Event" width="25%">
</div>
<br />
<br />
<br />

<!--  AUTH SECTION -->
