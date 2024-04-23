if @happy_thing.persisted?
  json.form do
    json.partial! "happy_things/form", happy_thing: HappyThing.new
  end
  json.inserted_item do
    json.partial! "happy_things/happy_thing", happy_thing: @happy_thing
  end
else
  json.form do
    json.partial! "happy_things/form", happy_thing: @happy_thing
  end
end
