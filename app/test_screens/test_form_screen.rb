class TestFormScreen < PM::FormScreen
  title "Account info"

  def form_data
    [{
      title: "Account Information",
      footer: "Some help text",
      cells: [{
        name: "email",
        title: "Email",
        type: :email,
        value: current_user.email,
      }, {
        name: "password",
        title: "Password",
        type: :password,
      }, {
        name: "date",
        title: "Date",
        type: :date,
      }]
    }, {
      title: "Second Section",
      cells: [{
        title: "Cell Without A Name",
        value: "",
        properties: {
          textLabel: {
            font: UIFont.fontWithName('Helvetica-Light', size: 25),
            color: UIColor.blueColor
          },
          backgroundColor: UIColor.lightGrayColor
        }
      }, {
      name: "readonly",
      label: "Test",
      type: :text,
      value: "Using Label",
    },]
    }, {
      title: "Custom Cell Class",
      cells: [{
        title: "Test Cell",
        value: "Test Custom Class",
        cell_class: MyCustomCell
      }]
    }, {
      title: "Image Section",
      cells: [{
        title: "Cell with UIImage",
        value: "",
        image: UIImage.imageNamed('test')
      },{
        title: "Cell with String Image",
        value: "",
        image: 'test'
      }]
    }, {
      title: "Bad Data Scenarios", # the existence of these scenarios should not cause the app to crash
      cells: [
        { }, # nothing!
        { title: nil },
        { title: '' }, # title as an empty string with no fallbacks
        { title: '', label: 'Test Label' }, # since title is not nil, label is not applied
      ]
    }, {
      title: "Boolean Values Section",
      cells: [{
        title: "Cell with false boolean",
        type: :boolean,
        value: false
      }, {
        title: "Cell with 1 as boolean",
        type: :boolean,
        value: 1
      },{
        title: "Cell with empty",
        type: :boolean
      }]
    }]
  end

  def current_user
    Struct.new(:email, :password).new("jamon@example.com", "testing123456")
  end

end
