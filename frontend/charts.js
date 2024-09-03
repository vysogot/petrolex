// Set the dimensions and margins of each graph (adjusted for smaller size)
const margin = { top: 20, right: 30, bottom: 40, left: 50 },
    width = 400 - margin.left - margin.right,
    height = 150 - margin.top - margin.bottom;

// X and Y axis functions (these can be reused for all charts)
const x = d3.scaleLinear().range([0, width]);
const y = d3.scaleBand().range([0, height]).padding(.1);

// Initialize an empty object to store SVG elements by chart ID
const chartSvgs = {};

// Function to create a chart if it doesn't exist, or update it if it does
function createOrUpdateChart(chartId, data, title) {
    let svg;

    if (!chartSvgs[chartId]) {
        // Create a container div for the chart and title
        const chartContainer = d3.select(`div#${chartId}`);

        // Add title
        chartContainer.append("h3")
            .attr("class", "chart-title")
            .style("text-align", "center")
            .text(title);

        // Create the SVG element for the first time
        svg = chartContainer.append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", `translate(${margin.left},${margin.top})`);

        chartSvgs[chartId] = svg;

        // Append X and Y axis groups
        svg.append("g").attr("class", "x-axis").attr("transform", `translate(0,${height})`);
        svg.append("g").attr("class", "y-axis");
    } else {
        // Use the existing SVG
        svg = chartSvgs[chartId];
    }

    // Update X and Y domains
    x.domain([0, d3.max(data, d => d.value)]);
    y.domain(data.map(d => d.name));

    // Update axes
    svg.select(".x-axis").transition().duration(500).call(d3.axisBottom(x));
    svg.select(".y-axis").transition().duration(500).call(d3.axisLeft(y));

    // Bind data to bars
    const bars = svg.selectAll(".bar").data(data, d => d.name);

    // Enter new bars
    bars.enter()
        .append("rect")
        .attr("class", "bar")
        .attr("x", x(0))
        .attr("y", d => y(d.name))
        .attr("height", y.bandwidth())
        .attr("width", 0) // Initial width of 0 for animation
        .on("mouseover", (event, d) => {
            d3.select(".tooltip")
                .style("opacity", 1)
                .html(`Value: ${d.value}`)
                .style("left", (event.pageX + 5) + "px")
                .style("top", (event.pageY - 28) + "px");
        })
        .on("mouseout", () => {
            d3.select(".tooltip").style("opacity", 0);
        })
        .transition().duration(500)
        .attr("width", d => x(d.value));

    // Update existing bars
    bars.transition().duration(500)
        .attr("y", d => y(d.name))
        .attr("height", y.bandwidth())
        .attr("width", d => x(d.value));

    // Remove old bars
    bars.exit().transition().duration(500).attr("width", 0).remove();
}

// Function to fetch data and update the charts
function fetchDataAndUpdate() {
    const url = "charts.json?cacheBuster=" + new Date().getTime();
    d3.json(url).then(data => {
        console.log('Fetched data:', data);

        // Update charts for each metric
        Object.keys(data).forEach(metric => {
            createOrUpdateChart(metric, data[metric], metric);
        });
    }).catch(error => {
        console.error('Error loading the data:', error);
    });
}

// Create a container div for each metric initially
function initializeCharts(metrics) {
    const chartContainer = d3.select("div#charts");

    metrics.forEach(metric => {
        if (d3.select(`div#${metric}`).empty()) {
            chartContainer.append("div")
                .attr("id", metric)
                .attr("class", "chart-container")
                .style("display", "inline-block")
                .style("width", `${width + margin.left + margin.right}px`)
                .style("margin", "10px");
        }
    });
}

// Initial setup and periodic updates
const metrics = ["avaragespeed", "reserve", /* add more metrics here */];
initializeCharts(metrics);

// Fetch data and update the charts every 2 seconds
setInterval(fetchDataAndUpdate, 2000);

// Initial fetch to render the charts immediately
fetchDataAndUpdate();
