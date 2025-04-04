// js/loader.js
import { compileStreaming } from '../wasm/main.mjs'; // Import the necessary function

// Define the function Dart will call
window.dartScriptGetCode = function() {
    console.log('JS: window.dartScriptGetCode() called by Dart.');
    const dartScriptTag = document.querySelector('dart-script'); // Find the first tag
    if (dartScriptTag) {
        console.log('JS: Found <dart-script> tag, returning textContent.');
        return dartScriptTag.textContent;
    } else {
        console.warn('JS: No <dart-script> tag found.');
        return null; // Return null if no tag found
    }
};

async function loadDartModule() {
    const outputDiv = document.getElementById('output');
    outputDiv.textContent = 'Loading Dart WASM module...';

    try {
        // 1. Fetch the WASM file
        const wasmResponse = await fetch('wasm/main.wasm');
        if (!wasmResponse.ok) {
            throw new Error(`Failed to fetch WASM module: ${wasmResponse.statusText}`);
        }

        // 2. Compile the WASM module using the generated JS helper
        outputDiv.textContent = 'Compiling WASM module...';
        const compiledApp = await compileStreaming(wasmResponse);

        // 3. Instantiate the compiled application
        outputDiv.textContent = 'Instantiating WASM module...';
        const instantiatedApp = await compiledApp.instantiate();

        // 4. Invoke the Dart main() function, which will call back to JS
        outputDiv.textContent = 'WASM module instantiated. Invoking Dart main()...';
        instantiatedApp.invokeMain();
        outputDiv.textContent = 'Dart main() invoked (should have called JS back).';

        // PoC Verification logic removed - focus is now on <dart-script> tags
    } catch (error) {
        console.error('Error loading or running Dart module:', error);
        // Ensure the error message is displayed in the output div
        outputDiv.textContent = `Error during WASM load/run: ${error.message}\n\nStack:\n${error.stack || '(no stack)'}`;
    }
}

// Run the loader function when the script executes
loadDartModule();
