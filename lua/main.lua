-- a Client is used to connect this app to a Place. arg[2] is the URL of the place to
-- connect to, which Assist sets up for you.
local client = Client(
    arg[2], 
    "material_test"
)

-- App manages the Client connection for you, and manages the lifetime of the
-- your app.
local app = App(client)

-- Assets are files (images, glb models, videos, sounds, etc...) that you want to use
-- in your app. They need to be published so that user's headsets can download them
-- before you can use them. We make `assets` global so you can use it throughout your app.
assets = {
    quit = ui.Asset.File("images/quit.png"),
    teapot = ui.Asset.File("teapot.obj"),
}
app.assetManager:add(assets)

-- mainView is the main UI for your app. Set it up before connecting.
-- 0, 1.2, -2 means: put the app centered horizontally; 1.2 meters up from the floor; and 2 meters into the room, depth-wise
-- 1, 0.5, 0.01 means 1 meter wide, 0.5 meters tall, and 1 cm deep.
-- It's a surface, so the depth should be close to zero.
local mainView = ui.Surface(ui.Bounds(0, 1.2, -2,   1, 0.5, 0.01))

-- Make it so that the grab button or right mouse button moves lets user move the view.
-- Instead of making mainView grabbable, you could also create a ui.GrabHandle and add it
-- as a subview, sort of like a title bar of a desktop window.
mainView.grabbable = true

-- Create a regular ol' button. Make it 2 dm wide and high, and 1dm deep.
-- The position refers to the center of the button, so it needs to be moved
-- 5cm out of the mainView so that the button lies on top of the surface,
-- instead of embedded inside of it.
local button = ui.Button(ui.Bounds(0.0, 0.05, 0.05,   0.2, 0.2, 0.1))
mainView:addSubview(button)


-- It's nice to provide a way to quit the app, too.
-- Here's also an alternative syntax for setting the size and position of something.
local quitButton = ui.Button(ui.Bounds{size=ui.Size(0.12,0.12,0.05)}:move( 0.52,0.25,0.025))
-- Use our quit texture file as the image for this button.
quitButton:setDefaultTexture(assets.quit)
quitButton.onActivated = function()
    app:quit()
end
mainView:addSubview(quitButton)

-- Tell the app that mainView is the primary UI for this app
app.mainView = mainView

local pots = {}
local count = 5
for roughness = 1, count do  
    for metalness = 1, count do
        local pot = ModelView(nil, assets.teapot)
        pot.bounds.size = Size(0.8, 0.5)
        pot.customSpecAttributes.material = {
            metalness = (metalness-1)/(count-1),
            roughness = (roughness-1)/(count-1),
        }
        pot.color = {0.4, 0, 0.4, 1}
        pot.bounds:scale(0.1, 0.1, 0.1)
        pot.bounds:move(-count/2 + roughness * pot.bounds.size.width, 0.4, -(metalness-1) * pot.bounds.size.height)
        mainView:addSubview(pot)
        table.insert(pots, pot)
    end
end
local rnd = math.random
button.onActivated = function()
    for _, pot in ipairs(pots) do
        pot.color = {rnd(), rnd(), rnd()}
        pot:updateComponents()
    end
end

-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()
