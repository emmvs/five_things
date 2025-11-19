module InstallPromptHelper
  def dismiss_install_prompt_if_present
    if page.has_selector?('button[data-install-prompt-target="dismissButton"]', wait: 3)
      find('button[data-install-prompt-target="dismissButton"]').click
    end
  end
end

RSpec.configure do |config|
  config.include InstallPromptHelper, type: :system
end

