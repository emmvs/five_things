# frozen_string_literal: true

if @happy_thing.persisted?
  json.form render(partial: 'happy_things/form', formats: :html, locals: { happy_thing: HappyThing.new })
  json.inserted_item render(partial: 'happy_things/happy_thing', formats: :html, locals: { happy_thing: @happy_thing })
else
  json.form render(partial: 'happy_things/form', formats: :html, locals: { happy_thing: @happy_thing })
end
