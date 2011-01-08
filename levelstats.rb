LevelTips = ["Welcome to Nightly Travels of a Witch!\nMartina has been wandering around in her sleep again... It has been a hard day for her, and we shouldn't let her awake.\nUse the mouse to fly around as a fairy, and lure the sleeping witch into her bed using the chocolate item. All girls love chocolate, even when asleep! Left-click items to use them, right-click to deselect.",
              "Make Martina step on magic circles to gently hover over obstacles.\nIf you get stuck, you can restart the level by clicking the red 'Restart' button. The blue ZZZ-o-meter indicates how close you are to awakening. If it fades completely, you lose and have to play the level again.",
              "Sleeping girls don't just keep their attraction to chocolate - the spider-squishing instinct is always active as well.\nMove the little spider in front of Martina and left-click to make her poke. You can use this to switch off lights which would otherwise awaken you.",
              "Now the time has come to utilize the powers of a witch. Feed her a chili to make her feel fiery, then scare her with her plush orc to make her cast fire magic while asleep, and burn bushes and webs!",
              "Another spell can be activated by gently feeding Martina ice cream, then provoking her with the Orc puppet. Her ice bolts will cool down cauldrons, freeze water and kill fire dwarves.",
              "When things are out of reach for you, you can place clouds as steps.",
              "Now try to combine what you have learnt!",
              "Clouds can also be used for blocking light.",
              "Congratulations. You have won!"]
LevelItems = [{ Items::Choco => 1, Items::Orc => 0, Items::Spider => 0, Items::Ice => 0, Items::Chili => 0, Items::Block => 0 },
              { Items::Choco => 1 },
              { Items::Choco => 1, Items::Spider => 4 },
              { Items::Choco => 1, Items::Orc => 1, Items::Chili => 5 },
              { Items::Choco => 1, Items::Orc => 1, Items::Ice => 10 },
              { Items::Choco => 1, Items::Block => 20 },
              { Items::Choco => 1, Items::Spider => 2, Items::Block => 5, Items::Chili => 2, Items::Ice => 2, Items::Orc => 1 },
              { Items::Choco => 1, Items::Block => 20 },
              { }
              ]
              
LevelCount = LevelTips.size
