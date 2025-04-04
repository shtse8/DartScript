// js/loader.js
// Static import removed - will import dynamically based on src attribute.

// window.dartScriptGetCode removed - inline script execution is no longer supported.
// The loader will be adapted to handle <dart-script src="..."> tags.
// --- DartScript Framework APIs (Callable from Dart WASM) ---

window.dartScriptSetText = function(selector, text) {
    console.log(`JS: dartScriptSetText called with selector='${selector}', text='${text}'`);
    try {
        const element = document.querySelector(selector);
        if (element) {
            element.textContent = text;
        } else {
            console.warn(`JS: dartScriptSetText - Element not found for selector: ${selector}`);
        }
    } catch (error) {
        console.error(`JS: Error in dartScriptSetText for selector '${selector}':`, error);
    }
};

// --- Module Loading Logic ---
async function loadDartScriptModules() {
    const outputDiv = document.getElementById('output');
    outputDiv.textContent = 'Searching for <dart-script src="..."> tags...';

    const dartScriptTags = document.querySelectorAll('dart-script[src]');

    if (dartScriptTags.length === 0) {
        outputDiv.textContent += '\nNo <dart-script src="..."> tags found.';
        return;
    }

    outputDiv.textContent += `\nFound ${dartScriptTags.length} tag(s). Loading modules...`;

    for (const tag of dartScriptTags) {
        const src = tag.getAttribute('src');
        if (!src) continue;

        // Convention: Assume WASM file has the same base name as the JS loader but with .wasm extension
        const wasmPath = src.replace(/\.mjs$/, '.wasm');
        if (wasmPath === src) {
            console.error(`Could not determine WASM path from src: ${src}. Skipping.`);
            outputDiv.textContent += `\nError: Invalid src format for ${src}. Expected .mjs extension.`;
            continue;
        }

        outputDiv.textContent += `\n\nLoading module from: ${src} (WASM: ${wasmPath})`;

        try {
            // 1. Dynamically import the JS loader module
            const jsModule = await import(src);

            if (!jsModule.compileStreaming) {
                 throw new Error(`JS module from ${src} does not export 'compileStreaming'.`);
            }

            // 2. Fetch the corresponding WASM file
            outputDiv.textContent += `\n  Fetching ${wasmPath}...`;
            const wasmResponse = await fetch(wasmPath);
            if (!wasmResponse.ok) {
                throw new Error(`Failed to fetch WASM module (${wasmPath}): ${wasmResponse.statusText}`);
            }

            // 3. Compile the WASM module using the imported helper
            outputDiv.textContent += `\n  Compiling ${wasmPath}...`;
            const compiledApp = await jsModule.compileStreaming(wasmResponse);

            // 4. Instantiate the compiled application
            outputDiv.textContent += `\n  Instantiating ${wasmPath}...`;
            const instantiatedApp = await compiledApp.instantiate();

            // 5. Invoke the Dart main() function
            outputDiv.textContent += `\n  Invoking main() for ${src}...`;
            instantiatedApp.invokeMain();
            outputDiv.textContent += `\n  Module ${src} loaded and main() invoked successfully.`;

        } catch (error) {
            console.error(`Error loading or running Dart module from ${src}:`, error);
            outputDiv.textContent += `\n\nError loading module ${src}:\n  ${error.message}\n  Stack: ${error.stack || '(no stack)'}`;
        }
    }
}

// Run the loader function after the DOM is fully loaded
document.addEventListener('DOMContentLoaded', loadDartScriptModules);
