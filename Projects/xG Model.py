#!/usr/bin/env python
# coding: utf-8

# In[5]:


get_ipython().system('pip install pandas numpy matplotlib seaborn mplsoccer scikit-learn')


# In[6]:


import pandas as pd
import numpy as np
rd = pd.read_csv('~/Downloads/xg_model.csv')


# In[7]:


rd.head()


# In[8]:


rd.shape


# In[9]:


rd.y.min()


# In[10]:


rd.columns


# In[11]:


rd.drop(['DirectFreekick', 'DirectCorner'], axis=1, inplace=True)


# In[12]:


rd.columns


# In[13]:


rd.OwnGoal.value_counts()

###
# In[14]:


rd = rd[rd['OwnGoal'] != True]
rd.drop('OwnGoal' , axis=1, inplace = True)


# In[15]:


rd.shape


# In[16]:


rd.is_goal.value_counts()


# In[17]:


import matplotlib.pyplot as plt
import seaborn as sns

plt.figure(figsize=(10,6))

sns.scatterplot(x = 'x', y = 'y', data = rd, hue = 'is_goal', alpha = .5)

###
# In[18]:


rd.isna().sum()


# In[19]:


rd.fillna(0, inplace=True)


# In[20]:


rd.dtypes


# In[21]:


rd = rd.astype({
    'x': float,
    'y': float,
    'is_goal': bool,
    'period': str,
    'Assisted': bool,
    'Zone': str,
    'IndividualPlay':bool,
    'RegularPlay':bool,
    'LeftFoot':bool,
    'RightFoot':bool,
    'FromCorner':bool,
    'FirstTouch':bool, 
    'Head':bool,
    'BigChance': bool,
    'SetPiece': bool,
    'Volley': bool,
    'FastBreak':bool,
    'ThrowinSetPiece':bool,
    'Penalty':bool, 
    'OneOnOne':bool,
    'KeyPass': bool,
    'OtherBodyPart': bool
})


# In[22]:


rd.dtypes


# In[23]:


###


# In[24]:


rd['shot_distance'] = np.sqrt((rd['x'] - 100)**2 + (rd['y'] - 50)**2)


# In[25]:


rd.shot_distance


# In[26]:


rd["shot_distance"].hist()


# In[27]:


rd['shot_distance'].describe()


# In[28]:


rd.period.value_counts()


# In[29]:


rd = pd.get_dummies(rd, columns=['period', 'Zone' ])


# In[30]:


rd.columns


# In[31]:


rd.period_FirstHalf.value_counts()


# In[32]:


rd.period_SecondHalf.value_counts()


# In[33]:


###


# In[34]:


x = rd.drop('is_goal', axis=1)
y = rd['is_goal']


# In[35]:


from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import log_loss, roc_auc_score, brier_score_loss


# In[36]:


x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = .2, random_state = 42)


# In[37]:


model = LogisticRegression(max_iter = 1000)


# In[38]:


model.fit(x_train, y_train)


# In[39]:


y_pred_proba = model.predict_proba(x_test)[:,1]


# In[40]:


y_pred_proba[:10]


# In[41]:


final_rd = x_test.copy()
final_rd['goal_probability'] = y_pred_proba


# In[42]:


final_rd.iloc[98]


# In[43]:


final_rd.sort_values(by= 'goal_probability', ascending = False).head()


# In[44]:


log_loss(y_test, y_pred_proba)


# In[45]:


roc_auc_score(y_test, y_pred_proba)


# In[46]:


brier_score_loss(y_test, y_pred_proba)


# In[47]:


from mplsoccer import Pitch
pitch = Pitch(pitch_type = 'opta')


# In[48]:


from matplotlib.colors import LinearSegmentColormap
colors = ['red', 'yellow', 'green']

cmap = LinearSegementedColormap.fromlist('my_colormap', colors)


# In[49]:


sc = pitch.scatter(
    final_df['x'], 
    final_df['y'],  
    c=final_df['goal_probability'],  
    cmap=cmap,  
    edgecolors='black', linewidth=0.5, s=100,  
    ax=ax
)

cbar = plt.colorbar(sc, ax=ax, orientation='vertical', fraction=0.02, pad=0.02)
cbar.set_label('xG Probability')


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




