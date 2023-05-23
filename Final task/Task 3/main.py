from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time


def open_url_in_browser(url):
    # Set up the Chrome options to open in incognito mode
    chrome_options = Options()
    chrome_options.add_argument("--incognito")

    # Set up the web driver with the specified options
    driver = webdriver.Chrome(options=chrome_options)

    try:
        # Open the URL in the web browser
        driver.get(url)

        # Wait for the page to load (you can modify the sleep duration if needed)
        time.sleep(10)

        # Find and click on the "Show Advanced ID Details" button
        advanced_id_button = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "details-button"))
        )
        advanced_id_button.click()

        # Wait for the advanced ID details to expand
        time.sleep(10)

        # Find and click on the "Proceed" link
        proceed_link = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "proceed-link"))
        )
        proceed_link.click()

        # Wait for the advanced ID details to expand
        time.sleep(10)

        # Find and click on the epam-sso
        proceed_link = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.ID, "social-epam-idp"))
        )
        proceed_link.click()

        # Wait for the user to log in and the desired page to load
        WebDriverWait(driver, 300).until(
            EC.url_to_be(
                url)
        )
        print('Log in correct')

        # Launch Jupyter Notebook automatically
        # Open the dropdown menu
        time.sleep(10)
        dropdown_menu = WebDriverWait(driver, 500).until(
            EC.presence_of_element_located((By.ID, "celllink"))
        )
        dropdown_menu.click()

        # Click on the "run_all_cells" option
        run_all_cells_option = WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.ID, "run_all_cells"))
        )
        ActionChains(driver).move_to_element(run_all_cells_option).click().perform()
        print('Notebook run succcesfully')
        # Wait for check the results
        time.sleep(10)

    except:
        print("Timeout too long")
    finally:
        # Close the web driver
        driver.quit()
        print("Close driver")


url = "https://dqelearn.trainings.dlabanalytics.com/aviktarovich/notebooks/AViktarovich%20Final%20Task%202.ipynb"
open_url_in_browser(url)
