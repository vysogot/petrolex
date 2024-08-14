// Set the dimensions and margins of the graph
const margin = { top: 20, right: 30, bottom: 40, left: 90 },
    width = 800 - margin.left - margin.right,
    height = 400 - margin.top - margin.bottom;

// Append the SVG object to the body of the page
const svg = d3.select("body")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", `translate(${margin.left},${margin.top})`);

// X axis
const x = d3.scaleLinear()
    .range([0, width]);

const xAxis = svg.append("g")
    .attr("transform", `translate(0,${height})`);

// Y axis
const y = d3.scaleBand()
    .range([0, height])
    .padding(.1);

const yAxis = svg.append("g");

// Function to update the chart with new data
function updateChart(data) {
    // Update X axis
    x.domain([0, d3.max(data, d => d.value)]);
    xAxis.transition().duration(500).call(d3.axisBottom(x));

    // Update Y axis
    y.domain(data.map(d => d.name));
    yAxis.transition().duration(500).call(d3.axisLeft(y));

    // Append a div for the tooltip
    const tooltip = d3.select("body").append("div")
    .attr("class", "tooltip")
    .style("opacity", 0)
    .style("position", "absolute")
    .style("background-color", "white")
    .style("border", "solid")
    .style("border-width", "1px")
    .style("border-radius", "5px")
    .style("padding", "10px");

    // Bind data to bars
    const bars = svg.selectAll(".bar")
        .data(data, d => d.name);

    // Enter new bars
    bars.enter()
        .append("rect")
        .attr("class", "bar")
        .attr("x", x(0))
        .attr("y", d => y(d.name))
        .attr("height", y.bandwidth())
        .attr("width", 0) // Initial width of 0 for animation
        .on("mouseover", (event, d) => {
            tooltip.transition().duration(200).style("opacity", .9);
            tooltip.html(`Value: ${d.value}`)
                .style("left", (event.pageX + 5) + "px")
                .style("top", (event.pageY - 28) + "px");
        })
        .on("mouseout", () => {
            tooltip.transition().duration(500).style("opacity", 0);
        })
        .transition().duration(500)
        .attr("width", d => x(d.value));

    // Update existing bars
    bars.transition().duration(500)
        .attr("y", d => y(d.name))
        .attr("height", y.bandwidth())
        .attr("width", d => x(d.value));

    // Remove old bars
    bars.exit()
        .transition().duration(500)
        .attr("width", 0)
        .remove();
}

// Function to fetch data and update the chart
function fetchDataAndUpdate() {
    const url = "data.json?cacheBuster=" + new Date().getTime();
    d3.json(url).then(data => {
        // Debugging: Log fetched data
        console.log('Fetched data:', data);

        // Process the data
        data.forEach(d => {
            d.value = +d.value;
        });

        // Update the chart with the new data
        updateChart(data);
    }).catch(error => {
        console.error('Error loading the data:', error);
    });
}

// Fetch data and update the chart every 2 seconds
setInterval(fetchDataAndUpdate, 2000);

// Initial fetch to render the chart immediately
fetchDataAndUpdate();
