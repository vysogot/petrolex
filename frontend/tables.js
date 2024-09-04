// Function to convert time from seconds to human-readable format
function formatTime(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);

    let timeStr = '';
    if (hours > 0) {
        timeStr += `${hours}h `;
    }
    if (minutes > 0) {
        timeStr += `${minutes}m `;
    }
    if (secs > 0) {
        timeStr += `${secs}s`;
    }
    return timeStr.trim();
}

// Function to convert metric names to title case for display
function convertToTitleCase(metric) {
    return metric
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

// Function to create or update tables for each metric
function createTables() {
    const url = "charts.json?cacheBuster=" + new Date().getTime();
    fetch(url)
        .then(response => response.json())
        .then(data => {
            // Clear existing tables
            document.getElementById('tables').innerHTML = '';

            // Process each metric in the data
            Object.keys(data).forEach(metric => {
                const tableId = metric; // use the metric name as the table ID
                const title = convertToTitleCase(metric); // convert to title case for the table title

                // Create a table container
                const tableContainer = document.createElement('div');
                tableContainer.className = 'table-container';
                tableContainer.id = tableId;

                // Add title
                const tableTitle = document.createElement('h3');
                tableTitle.className = 'table-title';
                tableTitle.textContent = title;
                tableContainer.appendChild(tableTitle);

                // Create the table
                const table = document.createElement('table');
                table.className = 'metric-table';

                // Create the table header
                const thead = document.createElement('thead');
                const headerRow = document.createElement('tr');
                const headers = ['Name', 'Value'];
                headers.forEach(headerText => {
                    const th = document.createElement('th');
                    th.textContent = headerText;
                    headerRow.appendChild(th);
                });
                thead.appendChild(headerRow);
                table.appendChild(thead);

                // Create the table body
                const tbody = document.createElement('tbody');
                data[metric]
                    .sort((a, b) => metric.toLowerCase().includes('time') ? a.value - b.value : b.value - a.value)
                    .forEach((item, index) => {
                        const row = document.createElement('tr');
                        const nameCell = document.createElement('td');
                        nameCell.textContent = item.name;
                        const valueCell = document.createElement('td');
                        valueCell.textContent = metric.toLowerCase().includes('time') ? formatTime(item.value) : item.value;
                        row.appendChild(nameCell);
                        row.appendChild(valueCell);

                        // Make the first row bold
                        if (index === 0) {
                            row.querySelectorAll('td').forEach(cell => cell.style.fontWeight = 'bold');
                        }

                        tbody.appendChild(row);
                    });
                table.appendChild(tbody);

                // Append table to container
                tableContainer.appendChild(table);

                // Append table container to the main div
                document.getElementById('tables').appendChild(tableContainer);
            });
        })
        .catch(error => {
            console.error('Error loading the data:', error);
        });
}

// Initial fetch to render the tables immediately
createTables();

// Fetch data and update the tables every 2 seconds
setInterval(createTables, 2000);
