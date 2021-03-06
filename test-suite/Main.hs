import Universum

import qualified Test.Tasty
import Test.Tasty.Hspec
import qualified Data.Text as Text

import qualified Require

main :: IO ()
main = do
    test <- testSpec "require" spec
    Test.Tasty.defaultMain test


spec :: Spec
spec = parallel $ do
  it "transforms the 'require' keyword into a properly qualified import" $ do
    let input    = "require Data.Text"
    let expected = "import qualified Data.Text as Text"
    let actual   = Require.transform (Require.FileName "Foo.hs") input
    expected `Text.isInfixOf` actual

  it "imports the type based on the module" $ do
    let input    = "require Data.Text"
    let expected = "import Data.Text (Text)"
    let actual   = Require.transform (Require.FileName "Foo.hs") input
    expected `Text.isInfixOf` actual

  it "keeps the rest of the content intact" $ do
    let input                   = "module Foo where\nrequire Data.Text\nfoo = 42"
    let expectedModule          = "module Foo where"
    let expectedTypeImport      = "import Data.Text (Text)"
    let expectedQualifiedImport = "import qualified Data.Text as Text"
    let expectedContent         = "foo = 42\n"
    let actual                  = toString $ Require.transform (Require.FileName "Foo.hs") input
    actual `shouldStartWith` expectedModule
    actual `shouldContain`   expectedTypeImport
    actual `shouldContain`   expectedQualifiedImport
    actual `shouldEndWith`   expectedContent

  it "aliases the modules properly" $ do
    let input = "require Data.Text as Foo"
    let expectedTypeImport = "import Data.Text (Text)"
    let expectedQualifiedImport = "import qualified Data.Text as Foo"
    let actual = toString $ Require.transform (Require.FileName "Foo.hs") input
    actual `shouldContain`   expectedTypeImport
    actual `shouldContain`   expectedQualifiedImport

  it "imports the types properly" $ do
    let input = "require Data.Text (Foo)"
    let expectedTypeImport = "import Data.Text (Foo)"
    let expectedQualifiedImport = "import qualified Data.Text as Text"
    let actual = toString $ Require.transform (Require.FileName "Foo.hs") input
    actual `shouldContain`   expectedTypeImport
    actual `shouldContain`   expectedQualifiedImport

  it "imports the types and aliases the modules properly" $ do
    let input = "require Data.Text as Quux (Foo)"
    let expectedTypeImport = "import Data.Text (Foo)"
    let expectedQualifiedImport = "import qualified Data.Text as Quux"
    let actual = toString $ Require.transform (Require.FileName "Foo.hs") input
    actual `shouldContain`   expectedTypeImport
    actual `shouldContain`   expectedQualifiedImport

