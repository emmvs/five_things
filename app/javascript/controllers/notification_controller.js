// import { Controller } from "@hotwired/stimulus"

// // Connects to data-controller="notification"
// export default class extends Controller {
//   static targets = ["notification", "newHappyThingform", "happyThings"]

//   connect() {
//     // console.log("👻 buh from notifications");
//     // console.log("newHappyThingform", this.newHappyThingformTarget);
//     // console.log("happyThings", this.happyThingsTarget);
//     // console.log("notification", this.notificationTarget);

//     this.registration = null;

//     navigator.serviceWorker.getRegistration().then(reg => {
//       this.registration = reg;
//       this.checkServiceWorkerRegistration();
//       // Listen for Turbo Stream updates for new happy things
//       this.element.addEventListener("turbo:after-stream-render", () => {
//         const message = "A new happy thing was added!";
//         this.sendNotification(message);
//       });
//     });
//   }

//   send(event) {
//     event.preventDefault();

//     // action = gives us the URL
//     fetch(this.newHappyThingformTarget.action, {
//       method: "POST",
//       headers: { "Accept": "application/json" },
//       body: new FormData(this.newHappyThingformTarget)
//     })
//       .then(response => response.json())
//       .then((data) => {
//         // console.log(data);
//         // console.log(data.happy_thing.user_id);
//         const message = `A new happy thing was added by user ${data.happy_thing.user_id}: ${data.happy_thing.title}`;
//         console.log(message);
//         this.sendNotification(message);
//       })
//   }

//   checkServiceWorkerRegistration() {
//     if ('serviceWorker' in navigator) {
//       navigator.serviceWorker.ready.then(reg => {
//         this.registration = reg;
//         // console.log("Service Worker is ready and registered:", reg);
//       }).catch(error => {
//         console.error("Service Worker registration failed:", error);
//       });
//     } else {
//       console.log("Service Workers are not supported in this browser.");
//     }
//   }

//   async sendNotification() {
//     // event.preventDefault();
//     if (Notification.permission === 'granted') {
//       this.showNotification(this.notificationTarget.value);
//     } else {
//       if (Notification.permission !== 'denied') {
//         const permission = await Notification.requestPermission();
//         if (permission === 'granted') {
//           this.showNotification(this.notificationTarget.value);
//         }
//       }
//     }
//   }

//   showNotification(body) {
//     const title = 'Five Things';
//     // What is a payload?
//     // Create a payload object that includes the body of the notification.
//     const payload = { body };
//     // Check if the showNotification method is available on the Service Worker registration.
//     if ('showNotification' in this.registration) {
//       // If it is, use it to show the notification with the title and payload.
//       this.registration.showNotification(title, payload);
//     } else {
//       // If the Service Worker registration does not support showNotification,
//       // fall back to using the Notification constructor to display the notification.
//       new Notification(title, payload);
//     }
//   }
// }
