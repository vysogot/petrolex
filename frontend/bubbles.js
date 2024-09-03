function createBubbleChart(data) {
  const width = 1400;
  const height = 700;

  const colorMapping = {
    "Full": "#32C809",      // Green
    "Being served": "#FF9800", // Orange
    "None": "#222222",
    "Partial": "#683012"
    // Add more mappings as needed
  };

  const color = d3.scaleLinear()
    .domain([0, 5])
    .range(["hsl(152,80%,80%)", "hsl(228,30%,40%)"])
    .interpolate(d3.interpolateHcl);

  const pack = data => d3.pack()
    .size([width, height])
    .padding(3)
    (d3.hierarchy(data)
      .sum(d => d.value)
      .sort((a, b) => b.value - a.value));
  let root = pack(data);

  const svg = d3.create("svg")
    .attr("viewBox", `-${width / 2} -${height / 2} ${width} ${height}`)
    .attr("width", width)
    .attr("height", height)
    .attr("style", `max-width: 100%; height: auto; display: block; margin: 0 -14px; background: ${color(0)}; cursor: pointer;`);

  const node = svg.append("g")
    .selectAll("circle")
    .data(root.descendants().slice(1))
    .join("circle")
    .attr("fill", d => colorMapping[d.data.name] || (d.children ? color(d.depth) : "white")) // Use the mapping or fallback
    .attr("pointer-events", d => !d.children ? "none" : null)
    .on("mouseover", function() { d3.select(this).attr("stroke", "#000"); })
    .on("mouseout", function() { d3.select(this).attr("stroke", null); })
    .on("click", (event, d) => focus !== d && (zoom(event, d), event.stopPropagation()));

  const label = svg.append("g")
    .style("font", "10px sans-serif")
    .attr("pointer-events", "none")
    .attr("text-anchor", "middle")
    .selectAll("text")
    .data(root.descendants())
    .join("text")
    .style("fill-opacity", d => d.parent === root ? 1 : 0)
    .style("display", d => d.parent === root ? "inline" : "none")
    .text(d => d.data.name);

  svg.on("click", (event) => zoom(event, root));

  let focus = root;
  let view = [focus.x, focus.y, focus.r * 2];
  zoomTo(view);

  function zoomTo(v) {
    const k = width / 2 / v[2];
    view = v;

    label.attr("transform", d => `translate(${(d.x - v[0]) * k},${(d.y - v[1]) * k})`);
    node.attr("transform", d => `translate(${(d.x - v[0]) * k},${(d.y - v[1]) * k})`);
    node.attr("r", d => d.r * k);
  }

  function zoom(event, d) {
    focus = d;

    const transition = svg.transition()
      .duration(event.altKey ? 7500 : 750)
      .tween("zoom", () => {
        const i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2]);
        return t => zoomTo(i(t));
      });

    label
      .filter(function(d) {
        // Filter to ensure all relevant labels (children, focus, and visible ancestors) are visible
        return d === focus || d.ancestors().includes(focus);
      })
      .transition(transition)
      .style("fill-opacity", d => d.parent === focus || d === focus ? 1 : 0)
      .style("display", d => d.parent === focus || d === focus || d.ancestors().includes(focus) ? "inline" : "none")
      .on("start", function(d) {
        if (d === focus || d.ancestors().includes(focus)) this.style.display = "inline";
      })
      .on("end", function(d) {
        if (!(d === focus || d.ancestors().includes(focus))) this.style.display = "none";
      });
  }

  // Returning essential parts for external control
  return {
    svg: svg.node(),
    zoomTo,
    getView: () => view,
    getFocus: () => focus,
  };
}

let data = {
  name: "root",
  children: [
      {name: "child 1", value: 100},
      {name: "child 2", value: 200},
      {
          name: "child 3", children: [
              {name: "grandchild 1", value: 50},
              {name: "grandchild 2", value: 150}
          ]
      }
  ]
};

// Create the chart and append it to the div
let chartContainer = document.getElementById("bubbles");
let chartInstance = createBubbleChart(data);
chartContainer.appendChild(chartInstance.svg);

// Function to update the chart with new data while preserving zoom state
function updateBubbleChart(newData) {
  // Preserve the current view and focus
  const currentView = chartInstance.getView();
  const currentFocus = chartInstance.getFocus();

  // Remove the old chart
  chartContainer.removeChild(chartInstance.svg);

  // Create a new chart with the updated data
  chartInstance = createBubbleChart(newData);

  // Append the new chart
  chartContainer.appendChild(chartInstance.svg);

  // Reapply the previous zoom state
  // chartInstance.zoomTo(currentView);
}

// Fetch new data and update the chart every second
setInterval(() => {
  const url = "bubbles.json?cacheBuster=" + new Date().getTime();
  fetch(url)
    .then((response) => response.json())
    .then((newData) => {
      updateBubbleChart(newData);  // Update the chart with the new data
    })
    .catch((error) => console.error("Error fetching data:", error));
}, 2000); // Update graph every second
