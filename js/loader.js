// js/loader.js
import { compileStreaming } from '../wasm/main.mjs'; // Import the necessary function

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

        // 4. Invoke the Dart main() function (which schedules the update)
        outputDiv.textContent = 'Invoking Dart main()...';
        instantiatedApp.invokeMain();
        outputDiv.textContent = 'Dart main() executed (update scheduled).';

        // 5. Verification - Wait briefly and check if Dart updated the DOM
        outputDiv.textContent += '\nWaiting for scheduled Dart update...';
        // Wait a bit longer to ensure the Timer callback has a chance to run
        await new Promise(resolve => setTimeout(resolve, 200)); // 200ms delay

        const expectedText = 'Hello from Dart WASM! 👋 (Timer.run)';
        if (outputDiv.textContent === expectedText) {
             outputDiv.textContent += '\nVerification successful: DOM updated by scheduled Dart code!';
             console.log('Verification successful.');
        } else {
            let errorMsg = '\nVerification failed:';
            errorMsg += `\n - Expected output text: "${expectedText}", but got: "${outputDiv.textContent}"`;
            outputDiv.textContent += errorMsg;
            console.error('Verification failed:', errorMsg);
        }

    } catch (error) {
        console.error('Error loading or running Dart module:', error);
        // Ensure the error message is displayed in the output div
        outputDiv.textContent = `Error during WASM load/run: ${error.message}\n\nStack:\n${error.stack || '(no stack)'}`;
    }
}

// Run the loader function when the script executes
loadDartModule();
