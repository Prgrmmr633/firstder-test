{% extends "base.html" %}
{% block title %}Index{% endblock %}
{% block content %}
<div class="p-4 bg-white shadow-md rounded-lg">
  <label
    class="block text-gray-700 text-4xl font-bold text-center pb-2"
    style="background-clip: text; -webkit-background-clip: text; color: transparent; background-image: linear-gradient(to right, #2563eb, #2dd4bf)"
  >
    Dermafy Now
  </label>
  <label class="block text-gray-700 text-2xl text-center py-4"> Instructions </label>
  <img src="{{ url_for('static', path='/asset/DermaInstruction.png') }}" alt="instructions" class="mx-auto h-72 rounded-lg" />
  
  <div class="flex flex-wrap justify-center">
    <!-- Form for Taking a Photo -->
    <form class="w-full md:w-auto" method="post" enctype="multipart/form-data" action="/image">
      <div class="flex -mx-3 py-1">
        <div class="w-full px-3">
          <div class="flex justify-between">
            <div class="w-1/2 h-36 flex items-center justify-center cursor-pointer bg-blue-400 text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-600 m-4" onclick="openWebcam()">
              <label for="takePhoto" class="text-center cursor-pointer text-3xl">
                Take A <br />
                Photo
              </label>
              <input class="opacity-0 absolute h-32 cursor-pointer" type="type" id="takePhoto" name="image" accept="image/*" required="required" value=""/>
            </div>
          </div>
          <!-- Webcam Modal (Shows webcam modal when the "Take A Photo" button is clicked) -->
        </div>
      </div>
      <div id="webcamModal" class="fixed inset-0 items-center justify-center z-10 hidden bg-black bg-opacity-40">
        <div class="flex items-center justify-center h-screen">
          <div class="bg-white m-auto p-5 border border-gray-300 shadow-lg rounded-lg w-3/5">
            <video id="video" class="my-4 mx-auto max-w-full shadow-lg rounded-lg max-h-full" autoplay></video>
            <button id="snap" class="w-full py-2 mt-2 bg-blue-500 text-white rounded hover:bg-blue-700">Snap Photo</button>
            <canvas id="canvas" class="my-4 mx-auto max-w-full shadow-lg rounded-lg max-h-full hidden"></canvas>
            <button id="done" class="w-full py-2 mt-2 bg-green-500 text-white rounded hover:bg-green-700 hidden" type="submit" name="submit">Done</button>
          </div>
        </div>
      </div>
      <div class="md:flex md:items-center justify-center" id="submitButtonContainer" style="display: none;">
        <div class="">
          <button class="shadow bg-blue-400 rounded-lg hover:bg-blue-600 focus:shadow-outline focus:outline-none text-white font-bold py-2 px-4" type="submit" name="submit">
            Submit
          </button>
        </div>
      </div>
    </form>

    <!-- Form for Uploading an Image -->
    <form class="w-full md:w-auto" method="post" enctype="multipart/form-data" action="/image">
      <div class="flex -mx-3 py-1">
        <div class="w-full px-3">
          <div class="flex justify-between">
            <div class="w-1/2 h-36 flex items-center justify-center cursor-pointer bg-blue-400 text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-600 m-4">
              <label for="uploadImage" class="text-center cursor-pointer text-3xl">
                Upload <br />
                An Image
              </label>
              <input class="opacity-0 absolute h-32 cursor-pointer" type="file" id="uploadImage" name="image" accept="image/*" onchange="toggleSubmitButtonVisibility(this)" />
            </div>
          </div>
        </div>
      </div>
      <div class="md:flex md:items-center justify-center" id="submitButtonContainer" style="display: none;">
        <div class="">
          <button class="shadow bg-blue-400 rounded-lg hover:bg-blue-600 focus:shadow-outline focus:outline-none text-white font-bold py-2 px-4" type="submit" name="submit">
            Submit
          </button>
        </div>
      </div>
    </form>
  </div>

  <div class="mt-4 text-center">
    <p class="text-gray-600 text-xs italic text-center">Take a Photo or Upload an Image to Submit a Picture</p>
    <a href="/results" class="bg-gray-400 hover:bg-gray-600 text-white font-bold py-2 px-4 rounded">View Past Results</a>
  </div>
  
  <script>
    function enableButtons() {
      var checkbox = document.getElementById("termsCheckbox");
      var submitButton = document.getElementById("submitButton");
  
      // Enable/disable submit button based on checkbox state
      submitButton.disabled = !checkbox.checked;
      window.location.href = "#content";
    }
  
    function toggleSubmitButtonVisibility(input) {
      var submitButtonContainer = document.getElementById('submitButtonContainer');
      submitButtonContainer.style.display = input.files.length > 0 ? 'block' : 'none';
    }
  
    document.addEventListener('invalid', (function () {
      return function (e) {
        e.preventDefault();
        document.getElementById("takePhoto").focus();
      };
    })(), true);
  
    // Open Webcam Function
    function openWebcam() {
      let imageData = null; // Variable to store the captured image data
      let counter = 1; // Counter for filename

      navigator.mediaDevices
        .getUserMedia({ video: true })
        .then(function (stream) {
          var video = document.getElementById("video");
          var canvas = document.getElementById("canvas");
          var snapButton = document.getElementById("snap");
          var doneButton = document.getElementById("done");
          var modal = document.getElementById("webcamModal");
          var submitButton = document.getElementById("submitButton");

          video.srcObject = stream;
          video.play();

          modal.style.display = "block";

          // Take Photo button function
          snapButton.addEventListener("click", function (event) {
            event.preventDefault(); // Prevent form submission

            // Adjust the size of the canvas to match the video stream
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;

            var context = canvas.getContext("2d");
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            video.style.display = "none";
            canvas.style.display = "block";
            snapButton.style.display = "none";
            doneButton.style.display = "block";

            // Convert the canvas image to a data URL
            imageData = canvas.toDataURL("image/png");
          });

            // Close the webcam modal when the "Done" button is clicked
            doneButton.addEventListener("click", async function () {
              if (imageData) { // Ensure there is captured image data
                  // Convert the data URL to a Blob
                  const blob = await fetch(imageData).then(response => response.blob());
                  
                  // Create a FormData object to send the image file
                  const formData = new FormData();
                  formData.append("image", blob, `webcam_photo.png`);
                  
                  // Send a POST request to the /image endpoint
                  try {
                      const response = await fetch("/image", {
                          method: "POST",
                          body: formData,
                      });
                      if (response.ok) {
                          console.log("Image uploaded successfully");

                          // Fetch predictions based on the latest image_url
                          const predictionResponse = await fetch("/predictionData", {
                              method: "GET",
                              headers: {
                                  "Content-Type": "application/json"
                              }
                          });
                          const predictionData = await predictionResponse.json();

                          // Check if predictionData is not undefined
                          if (predictionData && predictionData.image_url && predictionData.predictions && predictionData.confidence_scores) {
                              // Redirect to prediction.html with parameters
                              window.location.href = `/prediction.html?image_url=${predictionData.image_url}&predictions=${JSON.stringify(predictionData.predictions)}&confidence_scores=${JSON.stringify(predictionData.confidence_scores)}&read_more_urls=${JSON.stringify(predictionData.read_more_urls)}`;
                          } else {
                              console.error("Prediction data is undefined");
                          }
                      } else {
                          console.error("Failed to upload the image");
                      }
                  } catch (error) {
                      console.error("Error uploading the image:", error);
                  }

                  // Clear the value of the takePhoto input field
                  document.getElementById("takePhoto").value = '';
              }

              modal.style.display = "none";
              video.style.display = "block";
              canvas.style.display = "none";
              snapButton.style.display = "block";
              doneButton.style.display = "none";
            });
        })
        .catch(function (err) {
          console.error("Error accessing webcam:", err);
        });
    }
  </script>  
</div>
{% endblock content %}
