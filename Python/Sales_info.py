#Basic user info from input
name = input("Enter your name: ")

# Validate age (should be a number)
while True:
    age_input = input("Enter your age: ")
    if age_input.isdigit():
        age = int(age_input)
        break
    else:
        print("Age should be a number. Please try again.")

city = input("Enter your city: ")

print("User:", name)
print("Age:", age)
print("City:", city)

#Sales input from user
sales_input = input("Enter your sales amounts separated by commas (e.g., 100,250,90): ")
sales = [float(x.strip()) for x in sales_input.split(",")] #creates a list of what user input.
#float is for decimal places

high_sales = [] #creates a new list of high sales

#Check for high sales
print("Sales Overview:")
high_sales = []

for sale in sales:
    if sale > 200:
        print("High sale:", sale)
        high_sales.append(sale) #append adds sales item to high sales list

#Function to calculate average sale
def average(values):
    return round(sum(values) / len(values), 2) #len is the number of input values
print("Average sale amount:", average(sales))


#Summary
print("Total sales made:", len(sales))
print("Number of high sales:", len(high_sales))


#Sales with index positions using for loop + range
print("List of all sales:")
for i in range(len(sales)):
    print("Sale", i + 1, "amount:", sales[i])