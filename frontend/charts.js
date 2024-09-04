// Set the dimensions and margins of each graph (adjusted for smaller size)
const margin = { top: 20, right: 30, bottom: 40, left: 60 },
    width = 600 - margin.left - margin.right,
    height = 350 - margin.top - margin.bottom;

// X and Y axis functions (these can be reused for all charts)
const x = d3.scaleLinear().range([0, width]);
const y = d3.scaleBand().range([0, height]).padding(.1);

// Initialize an empty object to store SVG elements by chart ID
const chartSvgs = {};

// Function to convert metric names to title case for display
function convertToTitleCase(metric) {
    return metric
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

// Function to create a chart if it doesn't exist, or update it if it does
function createOrUpdateChart(chartId, data, title) {
    data.sort((a, b) => b.value - a.value);

    let svg;

    if (!chartSvgs[chartId]) {
        // Create a container div for the chart and title
        const chartContainer = d3.select("div#charts")
            .append("div")
            .attr("id", chartId)
            .attr("class", "chart-container")
            .style("display", "inline-block")
            .style("width", `${width + margin.left + margin.right}px`)
            .style("margin", "10px");

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

        // Append a div for the tooltip
        d3.select("body").append("div")
            .attr("class", "tooltip")
            .style("opacity", 0)
            .style("position", "absolute")
            .style("background-color", "white")
            .style("border", "solid")
            .style("border-width", "1px")
            .style("border-radius", "5px")
            .style("padding", "10px");
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

    // Add or update bar labels
    svg.selectAll(".bar-label")
        .data(data, d => d.name)
        .enter()
        .append("text")
        .attr("class", "bar-label")
        .attr("x", d => x(d.value) + 5) // Position slightly to the right of the bar
        .attr("y", d => y(d.name) + y.bandwidth() / 2)
        .attr("dy", ".35em")
        .attr("fill", "white")
        .style("text-anchor", "start")
        .text(d => d.value);

    svg.selectAll(".bar-label")
        .data(data, d => d.name)
        .transition().duration(500)
        .attr("x", d => x(d.value) + 5)
        .attr("y", d => y(d.name) + y.bandwidth() / 2)
        .text(d => d.value);
}

// Function to fetch data and update the charts
function fetchDataAndUpdate() {
    const url = "charts.json?cacheBuster=" + new Date().getTime();
    d3.json(url).then(data => {
        console.log('Fetched data:', data);

        // Process each metric in the data
        Object.keys(data).forEach(metric => {
            const chartId = metric; // use the metric name as the div ID
            const title = convertToTitleCase(metric); // convert to title case for the chart title

            // Create or update the chart
            createOrUpdateChart(chartId, data[metric], title);
        });
    }).catch(error => {
        console.error('Error loading the data:', error);
    });
}

// Fetch data and update the charts every 2 seconds
setInterval(fetchDataAndUpdate, 500);

// Initial fetch to render the charts immediately
fetchDataAndUpdate();
