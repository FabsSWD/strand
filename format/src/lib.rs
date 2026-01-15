#![forbid(unsafe_code)]

pub mod spec;
pub mod serialization;
pub mod deserialization;
pub mod types;

pub use spec::constants;
pub use deserialization::{DeserializeError, Deserializer, TokenHeader, TokenLayout};
pub use serialization::{SerializeError, Serializer};
pub use types::{Metadata, Token, TokenId, TokenRef, Value};
