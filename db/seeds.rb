User.create!(name:                  "Hau Nguyen",
             email:                 "haunttpd00207@gmail.com",
             password:              "111111",
             password_confirmation: "111111rou",
             admin:                 "true")

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:                  name,
               email:                 email,
               password:              password,
               password_confirmation: password)
end