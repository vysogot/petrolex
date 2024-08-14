// Sample data
const initialData = {
  nodes: [
    { id: "A", group: 1 },
    { id: "B", group: 2 },
    { id: "C", group: 2 },
    { id: "D", group: 2 },
    { id: "E", group: 2 },
  ],
  links: [
    { source: "B", target: "A", value: 2 },
    { source: "C", target: "A", value: 2 },
    { source: "D", target: "A", value: 2 },
    { source: "E", target: "A", value: 2 },
  ],
};

// Specify the dimensions of the chart.
const width = 928;
const height = 680;

// Specify the color scale.
const color = d3.scaleOrdinal(d3.schemeCategory10);

// Declare links and nodes with let so they can be reassigned
let links = initialData.links.map((d) => ({ ...d }));
let nodes = initialData.nodes.map((d) => ({ ...d }));

// Create a simulation with several forces.
const simulation = d3
  .forceSimulation(nodes)
  .force(
    "link",
    d3
      .forceLink(links)
      .id((d) => d.id)
      .strength(0)
  )
  .force("charge", d3.forceManyBody().strength(0))
  .force("x", d3.forceX().strength(0))
  .force("y", d3.forceY().strength(0));

// Create the SVG container.
const svg = d3
  .select("body")
  .append("svg")
  .attr("width", width)
  .attr("height", height)
  .attr("viewBox", [-width / 2, -height / 2, width, height])
  .attr("style", "max-width: 100%; height: auto;");

// Add a line for each link, and a circle for each node.
let link = svg
  .append("g")
  .attr("stroke", "#999")
  .attr("stroke-opacity", 0.6)
  .selectAll("line")
  .data(links)
  .join("line")
  .attr("stroke-width", (d) => Math.sqrt(d.value));

let node = svg
  .append("g")
  .attr("stroke", "#fff")
  .attr("stroke-width", 1.5)
  .selectAll("circle")
  .data(nodes)
  .join("circle")
  .attr("r", 5)
  .attr("fill", (d) => color(d.group))
  .call(
    d3.drag().on("start", dragstarted).on("drag", dragged).on("end", dragended)
  );

node.append("title").text((d) => d.id);

// Add a drag behavior.
function dragstarted(event) {
  if (!event.active) simulation.alphaTarget(0.3).restart();
  event.subject.fx = event.subject.x;
  event.subject.fy = event.subject.y;
}

function dragged(event) {
  event.subject.fx = event.x;
  event.subject.fy = event.y;
}

function dragended(event) {
  if (!event.active) simulation.alphaTarget(0);
  event.subject.fx = null;
  event.subject.fy = null;
}

// Set the position attributes of links and nodes each time the simulation ticks.
simulation.on("tick", () => {
  link
    .attr("x1", (d) => d.source.x)
    .attr("y1", (d) => d.source.y)
    .attr("x2", (d) => d.target.x)
    .attr("y2", (d) => d.target.y);

  node.attr("cx", (d) => d.x).attr("cy", (d) => d.y);
});

// Function to update the graph
function updateGraph(newData) {
  // Update the links and nodes data
  links = newData.links.map((d) => ({ ...d }));
  nodes = newData.nodes.map((d) => ({ ...d }));

  // Restart the simulation with the new data
  simulation.nodes(nodes);
  simulation.force("link").links(links);

  // Update the links selection
  link = link
    .data(links, (d) => `${d.source.id}-${d.target.id}`)
    .join(
      (enter) =>
        enter.append("line").attr("stroke-width", (d) => Math.sqrt(d.value)),
      (update) => update,
      (exit) => exit.remove()
    );

  // Update the nodes selection
  node = node
    .data(nodes, (d) => d.id)
    .join(
      (enter) =>
        enter
          .append("circle")
          .attr("r", 5)
          .attr("fill", (d) => color(d.group))
          .call(
            d3
              .drag()
              .on("start", dragstarted)
              .on("drag", dragged)
              .on("end", dragended)
          )
          .call((enter) => enter.append("title").text((d) => d.id)),
      (update) => update,
      (exit) => exit.remove()
    );

  // Restart the simulation with new nodes and links
  simulation.alpha(1).restart();
}

// Example of updating the graph with AJAX request every second
setInterval(() => {
  const url = "d3.json?cacheBuster=" + new Date().getTime();
  fetch(url)
    .then((response) => response.json())
    .then((newData) => {
      updateGraph(newData);
    })
    .catch((error) => console.error("Error fetching data:", error));
}, 1000); // Update graph every second
