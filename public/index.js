let categories;
let galleryView;
let leaving;
let arriving;

const MIN_COLOR_RATE = 0.01;
const MAX_COLOR_RATE = 0.1;
const MIN_SKEW = -15;
const MAX_SKEW = 15;
const MAX_SKEW_RATE = 0.025;

let albers = function(p) {
  let background;
  let colors = [];

  p.setup = function() {
    let els = p.selectAll('.gel');
    for (let e = 0; e < els.length; e++) {
      colors.push(new Project(els[e]));
    }
    p.noCanvas();
    p.colorMode(p.HSB, 255);
  }

  p.draw = function() {
    for (let c = 0; c < colors.length; c++) {
      colors[c].run();
    }
  }

  class Project {
    constructor(el) {
      this.i = 0;
      this.el = el;
      this.parent = new p5.Element(this.el.parent());
      this.skew = {
        x: p.random(MIN_SKEW, MAX_SKEW),
        y: p.random(MIN_SKEW, MAX_SKEW)
      }
      this.skews = {
        x: p.random(-MAX_SKEW_RATE, MAX_SKEW_RATE),
        y: p.random(-MAX_SKEW_RATE, MAX_SKEW_RATE)
      }
      this.rgb = {
        r: 0,
        g: 0,
        b: 0,
      };
      this.rgbs = {
        r: p.random(MIN_COLOR_RATE, MAX_COLOR_RATE),
        g: p.random(MIN_COLOR_RATE, MAX_COLOR_RATE),
        b: p.random(MIN_COLOR_RATE, MAX_COLOR_RATE),
      };

      this.a = 0.5; //this.el.elt.classList.contains('menu-bg') ? 0.5 : 0.5;
    }
    update() {
      for (let c in this.rgb) {
        this.rgb[c] += this.rgbs[c];
        if (this.rgb[c] > 255 || this.rgb[c] < 0) this.rgbs[c] *= -1;
      }

      for (let s in this.skew) {
        this.skew[s] += this.skews[s];
        if (this.skew[s] < MIN_SKEW || this.skew[s] > MAX_SKEW) this.skews[s] *= -1;
      }
    }
    run() {
      this.update();
      // Safari can only take integers for rgb
      this.el.style('background-color', 'rgba(' + p.round(this.rgb.r) + ',' + p.round(this.rgb.g) + ',' + p.round(this.rgb.b) + ',' + this.a + ')');
      let skew = 'skew(' + this.skew.x + 'deg, ' + this.skew.y + 'deg)';
      this.el.style('transform', skew);
    }
  }
}


// Helper function to load JSON files
function loadJSON(callback) {
  let xobj = new XMLHttpRequest();
  xobj.overrideMimeType("application/json");
  xobj.open('GET', 'projects.json', true);
  xobj.onreadystatechange = function() {
    if (xobj.readyState == 4 && xobj.status == "200") {
      // .open will NOT return a value but simply returns undefined in async mode so use a callback
      callback(xobj.responseText);
    }
  }
  xobj.send(null);
}
// Call to function with anonymous callback
loadJSON(function(response) {

  // Do Something with the response e.g.
  categories = JSON.parse(response);
  // Assuming json data is wrapped in square brackets as Drew suggests
  galleryView = Ractive({
    target: '#target',
    template: '#template',
    data: {
      categories: categories
    },
    complete: function() {
      new p5(albers);
      document.getElementById('menu-button').style.transform = 'skew(' + Math.random() * 5 + 'deg, ' + Math.random() * -5 + 'deg)';

      // Navigate directly to projects
      if(window.location.hash) {
        let id = window.location.hash.substring(1);
        document.getElementById('menu-' + id).click();
      }
    },
    showMenu: function() {
      if (arriving) leaving = arriving;
      arriving = undefined;
      this.hideProject(leaving.id);
      this.show('menu-container');
    },
    showProject: function(id, delay) {
      let self = this;
      setTimeout(function() {
        let elt = self.show(id);
        // Get top media item
        let top = elt.getElementsByClassName("media").item(0).children.item(0);
        if (top.tagName == "IFRAME") {
          top.contentWindow.postMessage('{"method":"play"}', '*');
        }
      }, delay ? 1000 : 0);
    },
    hideProject: function(id) {
      let elt = this.hide(id);
      // Pause all iframes
      let iframe = elt.getElementsByTagName('iframe')[0];
      if (iframe) iframe.contentWindow.postMessage('{"method":"pause"}', '*');
      setTimeout(function(){
        leaving.show = false;
        galleryView.update();
      }, 5000);
    },
    show: function(id) {
      let elt = document.getElementById(id);
      elt.classList.remove('hide');
      elt.classList.add('show');
      return elt;
    },
    hide: function(id) {
      let elt = document.getElementById(id);
      elt.classList.remove('show');
      elt.classList.add('hide');
      return elt;
    },
    enter: function(project) {
      // Arrive at new project
      arriving = project;

      // Update model
      arriving.show = true;
      galleryView.update();

      // Hide the menu
      this.hide('menu-container');
      // Showing arriving project
      this.showProject(arriving.id);
      console.log("Arriving: " + arriving.id);
      console.log(leaving ? "Leaving: " + leaving.id : "No project to leave.");

    }
  });
});
