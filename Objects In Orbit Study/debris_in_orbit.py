

print(data.head())
# filter the data by the column 'object_type'
data_type = data[data['OBJECT_TYPE'] == 'DEBRIS']
print(data_type.head())
# return list of unique values in column object_type
object_type = data['OBJECT_TYPE'].unique()
print(object_type)
# create correlation matrix
corr = data.corr()
print(corr)
#%%
