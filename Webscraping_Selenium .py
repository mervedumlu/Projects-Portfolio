#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 28 09:45:04 2023

@author: merve
"""

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import pandas as pd
import os
import codecs
from bs4 import BeautifulSoup



path = "~/Desktop/Projects"
options = webdriver.ChromeOptions()
options.add_argument('--disable-gpu')
options.add_argument("--disable-extensions")
prefs = {"profile.managed_default_content_settings.images": 2}
options.add_experimental_option("prefs", prefs)
options.add_argument('-no-sandbox')
options.add_argument('disable-infobars')
options.add_argument('headless')
options.add_argument('-disable-dev-shm-usage')

driver = webdriver.Chrome(executable_path=path, options = options)


for i in range(2006, 2020):
    url = "https://www.fangraphs.com/leaders/minor-league?pos=all&level=0&lg=2,4,5,6,7,8,9,10,11,14,12,13,15,16,17,18,30,32,33&stats=bat&qual=y&type=1&team=&season="+str(i)+"&seasonEnd="+str(i)+"&org=&ind=0&splitTeam=false&players=&sort=19,1&pageitems=10000000000000&pg=0"
    driver.get(url)
    table_webelement = driver.find_element(By.XPATH,
                                           "/html/body/div[1]/div[2]/div/div[2]/div/div/div[1]/div/div[1]/table")
    table_html = table_webelement.get_attribute("outerHTML") 
    # Save to an html file
    html = BeautifulSoup(table_html, "html.parser")
    stor = []
    for el in html.find_all("a", href = True):
        stor.append(el['href'])
    dataframes = pd.read_html(table_html)
    # ids = pd.DataFrame(stor)
    # stor_ids = ids[ids[0].str.contains("playerid")]
    # stor_ids = stor_ids.append(["None"])
    # stor_ids = stor_ids.reset_index(drop = True)
    data = dataframes[0]
    # cols = data.columns
    # data.columns = cols.get_level_values(1)
    # data.insert(1, "IDs", stor_ids, True)
    data["IDs"] = stor
    data.to_csv("~/Desktop/Projects/MILBBatting_adv" + str(i) +".csv")
    try:
        f = codecs.open("fangraphs_battingadv_milb"+ str(i) + ".html", "w", "utf−8")
        f.write(table_html)
    except:
        print('failed')
    print(i)

driver.close()




# rows = 1+len(driver.find_elements(By.XPATH,
#     "/html/body/div[1]/div[2]/div/div[2]/div/div/div[1]/div/div[1]/table/tbody/tr"))



# cols = len(driver.find_elements(By.XPATH,
#     "/html/body/div[1]/div[2]/div/div[2]/div/div/div[1]/div/div[1]/table/tbody/tr[1]/td"))

# headers = []
# for p in range(1, cols+1):
#     value = driver.find_element(By.XPATH,
#         "/html/body/div[1]/div[2]/div/div[2]/div/div/div[1]/div/div[1]/table/thead/tr/th["+str(p)+"]").text
#     headers.append(value)

# df = pd.DataFrame(columns = headers)
# df["Player ID"] = ""



# for r in range(1, rows):
#     row_dict = {}
#     for p in range(1, cols+1):
#         col_name= headers[p - 1]
#         # obtaining the text from each column of the table
#         value = driver.find_element(By.XPATH,
#             "/html/body/div[1]/div[2]/div/div[2]/div/div/div[1]/div/div[1]/table/tbody/tr["+str(r)+"]/td["+str(p)+"]").text
#         if col_name == "Name":
#             player_href = driver.find_element(By.XPATH,
#                 "/html/body/div[1]/div[2]/div/div[2]/div/div/div[1]/div/div[1]/table/tbody/tr["+str(r)+"]/td["+str(p)+"]/a")
#             href = player_href.get_attribute('href')
#             player_id = href.split("playerid=",1)[1]
#             row_dict["Player ID"] = player_id
#         row_dict[col_name] = value
#     df = df.append(row_dict, ignore_index = True)
#     if (r % 100) == 0: 
#         print(r)


# driver.close()
# driver.quit()

# sum(df["Player ID"].duplicated())

# df.to_csv("~/Desktop/Projects/MILB2022Batting.csv")


# "https://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=8&season=2019&month=0&season1=2019&ind=0&team=0&rost=0&age=0&filter=&players=0&startdate=&enddate=&page=1_50000"

master_milb = pd.DataFrame()

for i in range(2006, 2020): 
    df = pd.read_csv("~/Desktop/Projects/MILBPitching"+ str(i) +".csv")
    df["Year"] = i
    master_milb = pd.concat([master_milb, df])
    
 

master_mlb = pd.DataFrame()

for i in range(2006, 2023): 
    df = pd.read_csv("~/Desktop/Projects/MLBPitching"+ str(i) +".csv")
    df["Year"] = i
    master_mlb = pd.concat([master_mlb, df])


master_milb["Player ID"] = master_milb["IDs"].str.split("playerid=", expand = True)[1]

master_mlb["Player ID"] = (master_mlb["IDs"].str.split("playerid=", expand = True)[1]).str.split("&", expand = True)[0]



player_ids_shared = pd.merge(master_milb["Player ID"], master_mlb["Player ID"], on = "Player ID")


shared_milb = master_milb[master_milb["Player ID"].isin(player_ids_shared["Player ID"])]
shared_milb.drop(columns = {"Unnamed: 0", "#"}, inplace = True)
shared_mlb = master_mlb[master_mlb["Player ID"].isin(player_ids_shared["Player ID"])]


milb_career = shared_milb.copy()

milb_career = milb_career.drop_duplicates(subset = "Player ID")


    



shared_milb.to_csv("~/Desktop/Projects/MILB_Batting_adv.csv")
# shared_mlb.to_csv("~/Desktop/Projects/MLB_Pitching.csv")


    

    
