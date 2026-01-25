import asyncio
from playwright import async_api
from playwright.async_api import expect

async def run_test():
    pw = None
    browser = None
    context = None
    
    try:
        # Start a Playwright session in asynchronous mode
        pw = await async_api.async_playwright().start()
        
        # Launch a Chromium browser in headless mode with custom arguments
        browser = await pw.chromium.launch(
            headless=True,
            args=[
                "--window-size=1280,720",         # Set the browser window size
                "--disable-dev-shm-usage",        # Avoid using /dev/shm which can cause issues in containers
                "--ipc=host",                     # Use host-level IPC for better stability
                "--single-process"                # Run the browser in a single process mode
            ],
        )
        
        # Create a new browser context (like an incognito window)
        context = await browser.new_context()
        context.set_default_timeout(5000)
        
        # Open a new page in the browser context
        page = await context.new_page()
        
        # Navigate to your target URL and wait until the network request is committed
        await page.goto("http://localhost:3000", wait_until="commit", timeout=10000)
        
        # Wait for the main page to reach DOMContentLoaded state (optional for stability)
        try:
            await page.wait_for_load_state("domcontentloaded", timeout=3000)
        except async_api.Error:
            pass
        
        # Iterate through all iframes and wait for them to load as well
        for frame in page.frames:
            try:
                await frame.wait_for_load_state("domcontentloaded", timeout=3000)
            except async_api.Error:
                pass
        
        # Interact with the page elements to simulate user flow
        # -> Focus on the search input and type a query to test dynamic filtering.
        frame = context.pages[-1]
        # Type a query '데몬' in the search input to filter movies dynamically
        elem = frame.locator('xpath=html/body/div[2]/header/div/div[2]/div/div/input').nth(0)
        await page.wait_for_timeout(3000); await elem.fill('데몬')
        

        # -> Type a query that matches no movie and verify the 'No Results' message or screen.
        frame = context.pages[-1]
        # Type a query 'NoMatchMovie' that matches no movie to trigger 'No Results' screen
        elem = frame.locator('xpath=html/body/div[2]/header/div/div[2]/div/div/input').nth(0)
        await page.wait_for_timeout(3000); await elem.fill('NoMatchMovie')
        

        # -> Test keyboard support by typing additional characters, deleting them, and ensuring the search input updates results dynamically.
        frame = context.pages[-1]
        # Type 'No' in the search input to test keyboard support and dynamic filtering.
        elem = frame.locator('xpath=html/body/div[2]/header/div/div[2]/div/div/input').nth(0)
        await page.wait_for_timeout(3000); await elem.fill('No')
        

        # -> Delete text from the search input and verify the movie grid updates dynamically.
        frame = context.pages[-1]
        # Clear the search input to test dynamic update and keyboard support.
        elem = frame.locator('xpath=html/body/div[2]/header/div/div[2]/div/div/input').nth(0)
        await page.wait_for_timeout(3000); await elem.fill('')
        

        # --> Assertions to verify final state
        frame = context.pages[-1]
        await expect(frame.locator('text=거룩한 밤: 데몬 헌터스').first).to_be_visible(timeout=30000)
        await expect(frame.locator('text=검은 수녀들').first).to_be_visible(timeout=30000)
        await expect(frame.locator('text=No Results').first).to_be_visible(timeout=30000)
        await asyncio.sleep(5)
    
    finally:
        if context:
            await context.close()
        if browser:
            await browser.close()
        if pw:
            await pw.stop()
            
asyncio.run(run_test())
    