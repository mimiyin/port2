
var beedoo = beedoo || {};

$(document).ready(function(){
    var sketch = new p5(function(sketch) { 

      // Moving the shark
      var x = tx = 0;
      var bg = 255;

      // Keeping track of voices
      var maxVoices = 5; 
      var numVoices = 0;
      var voices = new doc.Voice(sketch);

      // Dartboard to control probabilities of
      // adding voices and picking wave types
      var vb = new doc.Dartboard(sketch, maxVoices, 2);

      // Pitches
      var pitches = [];
      var audios = sketch._userNode.getElementsByTagName('audio');
      for(var a = 0; a < audios.length; a++) {
        pitches.push(new doc.Pitch(sketch, audios[a]));
      }

      sketch.setup = function() {
        sketch.createCanvas($(window).width(), $(window).height());
        sketch.background(bg);
        sketch.noFill();
        
        // Let's run the same set of random numbers every time
        sketch.randomSeed(0);
        sketch.noLoop();
      }

      sketch.draw= function() {
        // Wrap the visualization
        x++;
        if (x > sketch.width*(tx + 1)) {
          tx++;
          sketch.background(bg);
        }
        sketch.push();
        sketch.translate(-sketch.width*tx, 0);

        //IF THERE ARE ACTIVE VOICES...
        if (numVoices > 0) {
          //Check each voice to see if it's dead
          for(var i = maxVoices-1; i >= 0; i--) { 
            if (voices[i] == null) {
              continue;
            }
            if (voices[i].isDead()) {
              numVoices--;
              // Cue up some voices if one died
              sketch.cue();
            }
            else if (voices[i].run()) {
                sketch.run(i);
            }
          }
        }
        // Cue up some voices if there are none
        else {
          sketch.cue();
        }
        sketch.pop();
      }

      sketch.run = function(v) {
        console.log("RUN", v);
        sketch.fill(0);
        var interval = sketch.height/(maxVoices+1);
        sketch.rect(x, (v+1)*(interval) - (interval/2), 5, 10);
        pitches[v].play();
      }

      // Decide how many voices to add
      sketch.cue = function() {
        var numToAdd = vb.fire() + 1;
        console.log("CUE", numToAdd);
        if (numToAdd > 0) {
          sketch.add(numToAdd);
        }
      }

      // Add a voice to any "dead" spots in the chorus
      sketch.add = function(max) {
        var numToAdd = max - numVoices;
        console.log("ADD", numToAdd);
        if (numToAdd == 0) {
          return;
        }
        for (var v = 0; v < maxVoices ; v++) {
          if (voices[v] == null || voices[v].isDead()) {
            if (numVoices >= numToAdd) {
              break;
            }
            voices[v] = new doc.Voice(sketch, v);
            numVoices++;
            console.log("NUM ACTIVE VOICES: " + numVoices);
          }
        }
      }
  }, document.getElementById("container-for-beedoo"));

  beedoo.sketch = sketch;
  $(beedoo.sketch._userNode).data("sketch", sketch);
});





