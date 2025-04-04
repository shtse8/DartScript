// js/app_bootstrap.js
// This script imports functions from the generated main.mjs
// and orchestrates the loading and execution of the Dart WASM app.

// Import the necessary function from the generated JS file
import { compileStreaming } from '../wasm/main.mjs';

// --- WASM Loading and Dart Main Invocation ---
(async () => {
  console.log(">>> Bootstrap: Script start (app_bootstrap.js).");
  try {
    // 1. Fetch and compile the WASM module
    console.log(">>> Bootstrap: Fetching and compiling wasm/main.wasm...");
    // Use the imported compileStreaming function
    const compiledApp = await compileStreaming(fetch('../wasm/main.wasm'));
    console.log(">>> Bootstrap: WASM compiled successfully.");

    // 2. Instantiate the module
    console.log(">>> Bootstrap: Instantiating WASM module...");
    // Pass an empty object for imports for now
    const instantiatedApp = await compiledApp.instantiate({});
    console.log(">>> Bootstrap: WASM instantiated successfully.");
    // console.log(">>> Bootstrap: Dart instance exports:", instantiatedApp.instantiatedModule.exports);

    // 3. Invoke the Dart main function
    console.log(">>> Bootstrap: Invoking Dart main function ($invokeMain)...");
    if (instantiatedApp.instantiatedModule.exports.$invokeMain) {
       instantiatedApp.invokeMain(); // Calls exports.$invokeMain([])
       console.log(">>> Bootstrap: Dart main function invoked.");
    } else {
       console.error(">>> Bootstrap: Error - $invokeMain not found in WASM exports!");
       // Fallback check (less likely needed with modern dart2wasm)
       if (instantiatedApp.instantiatedModule.exports.main) {
           console.log(">>> Bootstrap: Fallback: Invoking Dart main (old style)...");
           instantiatedApp.instantiatedModule.exports.main();
           console.log(">>> Bootstrap: Dart main (old style) invoked.");
       } else {
           console.error(">>> Bootstrap: Error - main export also not found!");
       }
    }

  } catch (error) {
    console.error(">>> Bootstrap: Error during WASM loading/execution:", error);
  }
  console.log(">>> Bootstrap: Script end (app_bootstrap.js).");
})();
// --- End of IIFE ---