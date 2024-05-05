import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="analytics"
export default class extends Controller {
  static values = {
    labels: Array,
    data: Array
  }

  connect() {
    this.drawChart();
  }

  drawChart() {
    const ctx = document.getElementById('dreamPieChart').getContext('2d');
    new Chart(ctx, {
      type: 'pie',
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: 'Happy Things Breakdown',
          data: this.dataValue,
          backgroundColor: [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
          ],
          borderColor: [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'top',
          },
        }
      }
    });
  }
}
