RSpec.configure do |config|
    config.before(:each, type: :feature) do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
            provider: 'google_oauth2',
            uid: '123456789',
            info: {
                name: 'Emma Doe',
                email: 'emmazing@gmail.com'
            }
        })
    end

    config.after(:each, type: :feature) do
        OmniAuth.config.mock_auth[:google_oauth2] = nil
    end
end